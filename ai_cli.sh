#!/data/data/com.termux/files/usr/bin/bash
#
# ai_cli.sh
# The universal AI command-line interface for Termux.
#
# Version: 1.0.0
#
# Usage:
#   echo "Hello" | ./ai_cli.sh -p -
#   ./ai_cli.sh -p "Translate 'hello' to French"
#   ./ai_cli.sh -f ./some_file.txt -s "Summarize this file"
#
# Safety:
# - Non-destructive by default (DRY_RUN=1).
# - Writes only to the termux-ai workspace.
# - Masks API keys in logs.
# - Times out API calls to prevent hangs.
#

# --- Strict Mode & Globals ---
set -Eeuo pipefail
IFS=$'\n\t'

# --- Version ---
VERSION="1.0.0"

# --- Script Info & Workspace ---
SCRIPT_NAME="$(basename "$0")"
CONFIG_DIR="$HOME/.config/termux-ai"
DATA_DIR="$HOME/.local/share/termux-ai"
OUT_DIR="$DATA_DIR/out"
CONFIG_FILE="$CONFIG_DIR/env"

# --- Load User Config ---
if [ -f "$CONFIG_FILE" ]; then
    # shellcheck source=/dev/null
    source "$CONFIG_FILE"
fi

# --- Helper Functions ---
# Usage: log "LEVEL" "message"
log() {
    local level="$1" msg="$2" color
    case "$level" in
        INFO) color='\033[0;32m' ;;
        WARN) color='\033[0;33m' ;;
        ERROR) color='\033[0;31m' ;;
        *) level="MSG"; color='\033[0m' ;;
    esac
    printf >&2 "${color}[%s] %s: %s\033[0m\n" "$(date +'%H:%M:%S')" "$level" "$msg"
}

die() {
    log "ERROR" "$1"
    exit 1
}

require_cmd() {
    command -v "$1" >/dev/null || die "Required command '$1' not found. Please install it. Example: pkg install $1"
}

usage() {
    echo "Termux AI Universal CLI v$VERSION"
    echo ""
    echo "Usage: $SCRIPT_NAME [options]"
    echo ""
    echo "Options:"
    echo "  -p, --prompt <text>   Prompt to send to the AI. Use '-' to read from stdin."
    echo "  -f, --file <path>     Use the content of a file as the prompt."
    echo "  -u, --url <url>       Use the content of a URL as the prompt."
    echo "  -s, --system <text>   System prompt or instruction."
    echo "  -m, --model <name>    Specify a model to use (e.g., gpt-4o-mini)."
    echo "      --provider <name> Force a provider ('openai' or 'gemini')."
    echo "      --no-save         Do not save the output to a file."
    echo "      --timeout <secs>  Set a timeout for the API call (default: 60)."
    echo "      --dry-run         Simulate run without writing files (default)."
    echo "  -v, --version         Show version information."
    echo "  -h, --help            Show this help message."
    echo ""
    echo "Examples:"
    echo "  echo 'Explain APIs' | $SCRIPT_NAME -p -"
    echo "  $SCRIPT_NAME -p 'Write a git commit message for a new feature'"
    echo "  $SCRIPT_NAME -f 'code.py' -s 'Review this Python code for bugs'"
}

# --- Provider API Call Functions ---

openai_call() {
    local prompt="$1" system_prompt="$2" model="$3" api_key="$4"
    log "INFO" "Using OpenAI provider with model '$model'"

    local messages_json
    messages_json=$(jq -n --arg role "user" --arg content "$prompt" \
        '[{"role": $role, "content": $content}]')

    if [[ -n "$system_prompt" ]]; then
        messages_json=$(echo "$messages_json" | jq --arg role "system" --arg content "$system_prompt" '[{"role": $role, "content": $content}] + .')
    fi

    local payload
    payload=$(jq -n --arg model "$model" --argjson messages "$messages_json" \
        '{model: $model, messages: $messages, stream: true}')

    local full_response=""
    local line
    while read -r line; do
        if [[ "$line" == "data: [DONE]" ]]; then
            break
        fi
        if [[ "$line" == "data: "* ]]; then
            local chunk
            chunk="${line#data: }"
            local content
            content=$(echo "$chunk" | jq -r '.choices[0].delta.content // ""')
            if [[ -n "$content" ]]; then
                printf "%s" "$content"
                full_response+="$content"
            fi
        fi
    done < <(curl -sS --no-buffer -X POST "https://api.openai.com/v1/chat/completions" \
        -H "Authorization: Bearer $api_key" \
        -H "Content-Type: application/json" \
        --data "$payload" \
        --max-time "${AI_TIMEOUT:-60}")

    echo "$full_response"
}

gemini_call() {
    local prompt="$1" system_prompt="$2" model="$3" api_key="$4"
    log "INFO" "Using Gemini provider with model '$model'"

    local contents_json
    contents_json=$(jq -n --arg role "user" --arg text "$prompt" \
        '[{"role": $role, "parts": [{"text": $text}]}]')

    if [[ -n "$system_prompt" ]]; then
        # Gemini API has a dedicated system_instruction field
        # We prepend it to the user prompt for multi-turn consistency if not supported directly
        prompt="${system_prompt}\n\n${prompt}"
        contents_json=$(jq -n --arg role "user" --arg text "$prompt" \
        '[{"role": $role, "parts": [{"text": $text}]}]')
    fi

    local payload
    payload=$(jq -n --argjson contents "$contents_json" \
        '{contents: $contents}')

    local full_response=""
    local line
    while read -r line; do
        if [[ "$line" == "data: "* ]]; then
            local chunk
            chunk="${line#data: }"
            local content
            content=$(echo "$chunk" | jq -r '.candidates[0].content.parts[0].text // ""')
            if [[ -n "$content" ]]; then
                printf "%s" "$content"
                full_response+="$content"
            fi
        fi
    done < <(curl -sS --no-buffer -X POST "https://generativelanguage.googleapis.com/v1beta/models/$model:streamGenerateContent?key=$api_key" \
        -H "Content-Type: application/json" \
        --data "$payload" \
        --max-time "${AI_TIMEOUT:-60}")

    echo "$full_response"
}

# --- Main Logic ---
main() {
    # --- Check dependencies ---
    require_cmd "jq"
    require_cmd "curl"

    # --- Default values ---
    prompt=""
    input_file=""
    input_url=""
    system_prompt=""
    model=""
    provider="${PROVIDER:-}"
    no_save=0
    # Respect global DRY_RUN but allow override. Default to 1 (true).
    dry_run="${DRY_RUN:-1}"
    AI_TIMEOUT="${AI_TIMEOUT:-60}"

    # --- Argument parsing ---
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -p|--prompt) prompt="$2"; shift 2 ;;
            -f|--file) input_file="$2"; shift 2 ;;
            -u|--url) input_url="$2"; shift 2 ;;
            -s|--system) system_prompt="$2"; shift 2 ;;
            -m|--model) model="$2"; shift 2 ;;
            --provider) provider="$2"; shift 2 ;;
            --no-save) no_save=1; shift ;;
            --dry-run) dry_run=1; shift ;;
            --timeout) AI_TIMEOUT="$2"; shift 2;;
            -v|--version) echo "Termux AI CLI v$VERSION"; exit 0 ;;
            -h|--help) usage; exit 0 ;;
            *) die "Unknown option: $1";;
        esac
    done

    # --- Input validation and processing ---
    local input_source_count=0
    [[ -n "$prompt" ]] && ((input_source_count++))
    [[ -n "$input_file" ]] && ((input_source_count++))
    [[ -n "$input_url" ]] && ((input_source_count++))

    if [[ "$input_source_count" -gt 1 ]]; then
        die "Please provide only one input source: -p, -f, or -u."
    fi

    if [[ "$prompt" == "-" || (! -t 0 && -z "$input_file" && -z "$input_url") ]]; then
        log "INFO" "Reading prompt from stdin..."
        prompt=$(cat)
    elif [[ -n "$input_file" ]]; then
        log "INFO" "Reading prompt from file: $input_file"
        [[ ! -f "$input_file" ]] && die "File not found: $input_file"
        prompt=$(cat "$input_file")
    elif [[ -n "$input_url" ]]; then
        log "INFO" "Fetching prompt from URL: $input_url"
        prompt=$(curl -sL "$input_url") || die "Failed to fetch URL: $input_url"
    fi

    if [[ -z "$prompt" ]]; then
        die "Prompt is empty. Please provide a prompt via -p, -f, -u, or stdin."
    fi

    # --- Provider and API Key detection ---
    local api_key=""
    if [[ -z "$provider" ]]; then
        if [[ -n "${OPENAI_API_KEY-}" ]]; then
            provider="openai"
        elif [[ -n "${GEMINI_API_KEY-}" ]]; then
            provider="gemini"
        else
            die "No API key found. Set OPENAI_API_KEY or GEMINI_API_KEY in $CONFIG_FILE"
        fi
    fi

    case "$provider" in
        openai)
            [[ -z "${OPENAI_API_KEY-}" ]] && die "OpenAI provider selected, but OPENAI_API_KEY is not set."
            api_key="$OPENAI_API_KEY"
            [[ -z "$model" ]] && model="${MODEL_OPENAI:-gpt-4o-mini}"
            ;;
        gemini)
            [[ -z "${GEMINI_API_KEY-}" ]] && die "Gemini provider selected, but GEMINI_API_KEY is not set."
            api_key="$GEMINI_API_KEY"
            [[ -z "$model" ]] && model="${MODEL_GEMINI:-gemini-1.5-flash-latest}"
            ;;
        *)
            die "Invalid provider '$provider'. Choose 'openai' or 'gemini'."
            ;;
    esac

    # --- Cost warning ---
    local char_count=${#prompt}
    local token_estimate=$((char_count / 4))
    if [[ "$token_estimate" -gt 8000 ]]; then
        log "WARN" "Input is large (~${token_estimate} tokens). This may incur costs."
        read -p "Continue? (y/N) " -n 1 -r
        echo
        if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
            die "Operation cancelled by user."
        fi
    fi

    # --- Execute API Call ---
    local full_response
    log "INFO" "Sending request to AI. Please wait..."

    # We capture the full response from the subshell for saving, while also streaming to user.
    full_response=$(
        case "$provider" in
            openai) openai_call "$prompt" "$system_prompt" "$model" "$api_key" ;;
            gemini) gemini_call "$prompt" "$system_prompt" "$model" "$api_key" ;;
        esac
    )
    printf "\n" # Newline after streaming is complete

    # --- Save Output ---
    if [[ "$dry_run" -eq 1 ]]; then
        log "INFO" "Dry run is active. Output was not saved."
    elif [[ "$no_save" -eq 1 ]]; then
        log "INFO" "--no-save flag is active. Output was not saved."
    else
        mkdir -p "$OUT_DIR"
        local timestamp
        timestamp=$(date +'%Y%m%d_%H%M%S')
        local out_file="$OUT_DIR/${timestamp}_${provider}_${model}.txt"
        echo "$full_response" > "$out_file"
        log "INFO" "Output saved to $out_file"
    fi
}

# --- Run main ---
main "$@"
