#!/data/data/com.termux/files/usr/bin/bash
#
# prompt_evaluator.sh
# Evaluates whether a user prompt is vague or clear enough to proceed.
#
# This hook analyzes prompts to determine if they contain sufficient detail
# to execute effectively, or if they need clarification through the prompt-improver skill.
#
# Version: 1.0.0
#

set -Eeuo pipefail
IFS=$'\n\t'

# --- Script Info ---
SCRIPT_NAME="$(basename "$0")"

# --- Helper Functions ---
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

# Evaluation prompt template (~189 tokens as per spec)
EVALUATION_PROMPT_TEMPLATE='You are a prompt clarity evaluator. Analyze the following user prompt and determine if it is:

VAGUE: The prompt lacks critical details, context, or specificity needed to complete the task effectively.
Examples: "fix the bug", "make it better", "help me with code"

CLEAR: The prompt provides sufficient detail, context, or specificity to proceed with execution.
Examples: "Fix the null pointer exception in user_service.py line 42", "Optimize the database query in get_users() function"

USER PROMPT:
"""
{{PROMPT}}
"""

CONVERSATION HISTORY (if available):
"""
{{HISTORY}}
"""

Respond with ONLY one of these two words:
VAGUE or CLEAR

Your response:'

# --- Main Evaluation Function ---
evaluate_prompt() {
    local prompt="$1"
    local conversation_history="${2:-}"
    local provider="${3:-openai}"
    local api_key="${4:-}"
    
    if [[ -z "$prompt" ]]; then
        die "Prompt cannot be empty"
    fi
    
    if [[ -z "$api_key" ]]; then
        die "API key required for prompt evaluation"
    fi
    
    log "INFO" "Evaluating prompt clarity..."
    
    # Substitute prompt and history into template
    local evaluation_prompt="${EVALUATION_PROMPT_TEMPLATE//\{\{PROMPT\}\}/$prompt}"
    evaluation_prompt="${evaluation_prompt//\{\{HISTORY\}\}/$conversation_history}"
    
    # Call AI to evaluate
    local result=""
    if [[ "$provider" == "openai" ]]; then
        result=$(call_openai_eval "$evaluation_prompt" "$api_key")
    elif [[ "$provider" == "gemini" ]]; then
        result=$(call_gemini_eval "$evaluation_prompt" "$api_key")
    else
        die "Unknown provider: $provider"
    fi
    
    # Parse result
    result=$(echo "$result" | tr -d '[:space:]' | tr '[:lower:]' '[:upper:]')
    
    if [[ "$result" == "VAGUE" ]]; then
        echo "VAGUE"
        return 0
    elif [[ "$result" == "CLEAR" ]]; then
        echo "CLEAR"
        return 0
    else
        log "WARN" "Unexpected evaluation result: '$result'. Defaulting to CLEAR."
        echo "CLEAR"
        return 0
    fi
}

# --- Provider-specific API calls ---
call_openai_eval() {
    local prompt="$1"
    local api_key="$2"
    
    local messages_json
    messages_json=$(jq -n --arg content "$prompt" '[{"role": "user", "content": $content}]')
    
    local payload
    payload=$(jq -n --arg model "gpt-4o-mini" --argjson messages "$messages_json" \
        '{model: $model, messages: $messages, temperature: 0}')
    
    local response
    response=$(curl -sS -X POST "https://api.openai.com/v1/chat/completions" \
        -H "Authorization: Bearer $api_key" \
        -H "Content-Type: application/json" \
        --data "$payload" \
        --max-time 30)
    
    echo "$response" | jq -r '.choices[0].message.content // "CLEAR"'
}

call_gemini_eval() {
    local prompt="$1"
    local api_key="$2"
    
    local contents_json
    contents_json=$(jq -n --arg text "$prompt" '[{"role": "user", "parts": [{"text": $text}]}]')
    
    local payload
    payload=$(jq -n --argjson contents "$contents_json" '{contents: $contents}')
    
    local response
    response=$(curl -sS -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=$api_key" \
        -H "Content-Type: application/json" \
        --data "$payload" \
        --max-time 30)
    
    echo "$response" | jq -r '.candidates[0].content.parts[0].text // "CLEAR"'
}

# --- CLI Interface ---
usage() {
    echo "Prompt Evaluator Hook v1.0.0"
    echo ""
    echo "Usage: $SCRIPT_NAME [options]"
    echo ""
    echo "Options:"
    echo "  -p, --prompt <text>      Prompt to evaluate (required)"
    echo "  -h, --history <text>     Conversation history (optional)"
    echo "  --provider <name>        AI provider ('openai' or 'gemini', default: openai)"
    echo "  --api-key <key>          API key for the provider (required)"
    echo "  --help                   Show this help message"
    echo ""
    echo "Output:"
    echo "  Prints 'VAGUE' or 'CLEAR' to stdout"
    echo ""
    echo "Exit Codes:"
    echo "  0 - Success"
    echo "  1 - Error"
}

main() {
    local prompt=""
    local history=""
    local provider="openai"
    local api_key=""
    
    # Argument parsing
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -p|--prompt) prompt="$2"; shift 2 ;;
            -h|--history) history="$2"; shift 2 ;;
            --provider) provider="$2"; shift 2 ;;
            --api-key) api_key="$2"; shift 2 ;;
            --help) usage; exit 0 ;;
            *) die "Unknown option: $1" ;;
        esac
    done
    
    if [[ -z "$prompt" ]]; then
        die "Prompt is required. Use -p or --prompt."
    fi
    
    if [[ -z "$api_key" ]]; then
        die "API key is required. Use --api-key."
    fi
    
    # Evaluate and output result
    evaluate_prompt "$prompt" "$history" "$provider" "$api_key"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
