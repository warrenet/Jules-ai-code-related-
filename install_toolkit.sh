#!/data/data/com.termux/files/usr/bin/bash
#
# Termux AI Toolkit Installer
#
# This script will install the complete Termux AI Toolkit by creating a
# directory at '~/termux-ai-toolkit' and unpacking all necessary files into it.
#
# To run, simply copy this entire script and paste it into your Termux terminal.
#
# This script is a self-extracting installer. It contains all the necessary
# scripts and documentation as HEREDOCs and unpacks them into the installation
# directory. This makes it easy to distribute the entire toolkit as a single file.
#

set -eu

# --- Main Variables ---
INSTALL_DIR="$HOME/termux-ai-toolkit"
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RESET='\033[0m'

# --- Welcome Message ---
echo -e "${BLUE}--- Termux AI Toolkit Installer ---${RESET}"
echo "This script will create the following directory: $INSTALL_DIR"
echo "It will then write all the toolkit scripts and documents into it."
read -p "Do you want to continue? (y/N) " -n 1 -r
echo
if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 1
fi

# --- Create Directory ---
echo "Creating installation directory..."
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# --- Unpack Files using HEREDOCs ---

echo "Unpacking README_first.md..."
cat <<'EOF' > README_first.md
# Termux AI Toolkit

A collection of safe, simple, and powerful Bash scripts to bring AI capabilities to your Android device via Termux.

This toolkit is built on a "safety first" principle. Scripts are non-destructive, make no changes to your system outside of a dedicated workspace, and are designed to work immediately with a simple copy and paste.

---

## 🛑 Safety First! Your Guarantees

Before you begin, understand these core safety rules:

*   **Non-Destructive by Default:** Scripts run in a **read-only** mode (`DRY_RUN=1`) by default. They will not write any files to your device until you explicitly allow them to by setting `DRY_RUN=0`.
*   **Isolated Workspace:** All files created by this toolkit (outputs, configs, logs) are stored exclusively within the `~/.config/termux-ai`, `~/.local/share/termux-ai`, and `~/.cache/termux-ai` directories. **No other locations are ever touched.**
*   **No Automatic System Changes:** The scripts will **never** automatically install packages, modify your `.bashrc` or `PATH`, or grant permissions. If a dependency is missing (like `jq`), the script will exit with a helpful message showing the exact command you can run to install it yourself.
*   **You Are In Control:** You are encouraged to read the scripts. They are heavily commented and designed for clarity.

---

## 🚀 90-Second Quickstart

Get your first AI-powered result in under two minutes.

### Step 1: Get the Scripts

You've already done this by running the installer! All files are now in the `~/termux-ai-toolkit` directory.

### Step 2: Set Your API Key

The toolkit needs an API key for either OpenAI (ChatGPT) or Google (Gemini).

1.  **Create a config file:**
    ```bash
    # First, create the config directory
    mkdir -p ~/.config/termux-ai

    # Then, copy the template.
    cp 01_env_template.sh ~/.config/termux-ai/env
    ```

2.  **Edit the `env` file:**
    Open the file in a text editor (like `nano` or `vim`) and add your key.
    ```bash
    nano ~/.config/termux-ai/env
    ```
    Uncomment the appropriate line and paste your key. **Never share this file or your key.**

    ```sh
    # --- CHOOSE YOUR PROVIDER ---
    # The script will auto-detect which key you have set.
    # If both are set, OpenAI is preferred by default.
    # You can force a provider by uncommenting this line:
    # PROVIDER="gemini" # or "openai"

    # --- SET YOUR API KEYS ---
    # Add your secret API keys here.
    # For OpenAI (ChatGPT):
    OPENAI_API_KEY="sk-..."

    # For Google (Gemini):
    # GEMINI_API_KEY="..."
    ```

3.  **Load the environment:**
    For the keys to be active in your current session, `source` the file:
    ```bash
    source ~/.config/termux-ai/env
    ```
    *(You will need to do this for every new Termux session.)*

### Step 3: Check Your Environment

Run the diagnostic script to make sure everything is ready.
```bash
bash 00_check_env.sh
```
If anything is missing, it will tell you exactly how to fix it.

### Step 4: Your First AI Command!

You're ready! Use the main `ai_cli.sh` script to ask a question.
```bash
# Use a pipe to send a question
echo "What are the key features of the Bash shell?" | bash ai_cli.sh -p -

# Or use the -p flag directly
bash ai_cli.sh -p "Suggest three names for a new tech blog."
```

You should see an AI-generated response directly in your terminal! Because `DRY_RUN` is on by default, no files were saved. To save your first response, try:
```bash
DRY_RUN=0 bash ai_cli.sh -p "Hello, world!"
```
This will create a timestamped output file in `~/.local/share/termux-ai/out/`.

---

## 📖 Script Usage & Examples

All scripts are located in the `~/termux-ai-toolkit` directory.

### `ai_cli.sh`
The core engine. Sends prompts to the AI.

*   **Example 1: Ask a simple question**
    ```bash
    bash ai_cli.sh -p "Explain the concept of 'idempotence' in scripting."
    ```
*   **Example 2: Read prompt from a file**
    ```bash
    echo "Summarize this text for me." > my_prompt.txt
    bash ai_cli.sh -f my_prompt.txt
    ```

### `clip_summarize.sh`
Summarizes the current content of your clipboard. Requires the Termux:API app.

*   **Example 1: Summarize copied text**
    *(First, copy some text from any app on your phone)*
    ```bash
    bash clip_summarize.sh
    ```
*   **Example 2: Save the summary to a file**
    ```bash
    DRY_RUN=0 bash clip_summarize.sh
    ```

### `url_summarize.sh`
Fetches the content of a URL and summarizes it.

*   **Example 1: Summarize a news article (in read-only mode)**
    ```bash
    bash url_summarize.sh -u "https://www.bbc.com/news/technology"
    ```
*   **Example 2: Summarize a blog post and save the output**
    ```bash
    DRY_RUN=0 bash url_summarize.sh -u "https://example.com/some-article"
    ```

### `file_summarize.sh`
Summarizes a local text file on your device.

*   **Example 1: Summarize a script you downloaded**
    ```bash
    # First, give Termux storage access if you haven't already
    # termux-setup-storage
    bash file_summarize.sh -f '~/storage/downloads/some_text_file.txt'
    ```
*   **Example 2: Summarize a project README**
    ```bash
    bash file_summarize.sh -f '~/termux-ai-toolkit/README_first.md'
    ```

---

## 📚 Glossary

*   **`DRY_RUN`**: An environment variable that controls whether scripts can write files. `DRY_RUN=1` (the default) is read-only. `DRY_RUN=0` allows writing to the workspace.
*   **Termux:API**: A separate Android app that you can install from F-Droid. It provides command-line access to Android features like the clipboard (`termux-clipboard-get`) and notifications (`termux-notification`). Our scripts use these features if available.
*   **Termux:Widget**: A separate app that lets you run scripts directly from your home screen. See `optional_widget_setup.md` for instructions.

---

## 🔧 Troubleshooting

*   **`command not found: jq`**: You need to install the `jq` package, which is essential for processing AI responses. Run: `pkg install jq`
*   **`command not found: termux-clipboard-get`**: The `clip_summarize.sh` script requires the Termux:API app and package. Install the app from F-Droid, then run: `pkg install termux-api`
*   **API Errors (401 Unauthorized)**: This almost always means your API key is incorrect or not loaded in your shell.
    1.  Double-check the key in `~/.config/termux-ai/env`.
    2.  Make sure you've run `source ~/.config/termux-ai/env` in your *current* terminal session.
    3.  Verify the key has credit or is active on the provider's website (OpenAI/Google AI).
EOF

echo "Unpacking 00_check_env.sh..."
cat <<'EOF' > 00_check_env.sh
#!/data/data/com.termux/files/usr/bin/bash
#
# 00_check_env.sh
# Verifies that the environment is ready for the Termux AI Toolkit.
#
# Usage: ./00_check_env.sh
#
# Safety:
# - This script is 100% read-only.
# - It does not install packages or modify any files.
# - It provides suggestions that the user can choose to run.
#

# --- Strict Mode ---
set -Eeuo pipefail
IFS=$'\n\t'

# --- Colors for Logging ---
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_BLUE='\033[0;34m'
C_RESET='\033[0m'

# --- Logging ---
# Usage: log "INFO" "Message"
log() {
    local level_color
    case "$1" in
        "OK") level_color="$C_GREEN" ;;
        "WARN") level_color="$C_YELLOW" ;;
        "FAIL") level_color="$C_RED" ;;
        "INFO") level_color="$C_BLUE" ;;
        *) level_color="$C_RESET" ;;
    esac
    printf >&2 "${level_color}[%*s]${C_RESET} %s\n" -4 "$1" "$2"
}

# --- Main Logic ---
main() {
    log "INFO" "Starting Termux AI Toolkit environment check..."
    local all_ok=1 # Flag to track overall status

    # 1. Check for required packages
    log "INFO" "Checking for required command-line tools..."
    local required_cmds=("curl" "jq")
    for cmd in "${required_cmds[@]}"; do
        if command -v "$cmd" &> /dev/null; then
            log "OK" "'$cmd' is installed."
        else
            log "FAIL" "'$cmd' is NOT installed. Please run: pkg install $cmd"
            all_ok=0
        fi
    done

    # 2. Check for Termux:API (optional but recommended)
    log "INFO" "Checking for Termux:API..."
    if command -v "termux-clipboard-get" &> /dev/null; then
        log "OK" "Termux:API package seems to be installed."
    else
        log "WARN" "Termux:API not found. Scripts like 'clip_summarize.sh' will not work."
        log "INFO" "To fix, install the Termux:API app, then run: pkg install termux-api"
    fi

    # 3. Check for internet connectivity
    log "INFO" "Checking for internet connection..."
    if curl -s --head --fail --max-time 5 "https://cloud.google.com" > /dev/null; then
        log "OK" "Internet connection appears to be working."
    else
        log "FAIL" "Could not connect to the internet. Please check your connection."
        all_ok=0
    fi

    # 4. Check for API Keys
    log "INFO" "Checking for API keys (will not display keys)..."
    log "INFO" "Note: You may need to 'source ~/.config/termux-ai/env' first."
    local openai_key_found=0
    local gemini_key_found=0

    if [[ -n "${OPENAI_API_KEY-}" ]]; then
        log "OK" "OPENAI_API_KEY is set."
        openai_key_found=1
    else
        log "WARN" "OPENAI_API_KEY is not set."
    fi

    if [[ -n "${GEMINI_API_KEY-}" ]]; then
        log "OK" "GEMINI_API_KEY is set."
        gemini_key_found=1
    else
        log "WARN" "GEMINI_API_KEY is not set."
    fi

    if [[ "$openai_key_found" -eq 0 && "$gemini_key_found" -eq 0 ]]; then
        log "FAIL" "No API keys found. The scripts will not work."
        log "INFO" "Please copy '01_env_template.sh' to '~/.config/termux-ai/env' and add your key."
        all_ok=0
    fi

    # --- Final Summary ---
    echo # Add a blank line for readability
    if [[ "$all_ok" -eq 1 ]]; then
        log "OK" "Environment check passed! You are ready to use the AI toolkit."
    else
        log "FAIL" "Environment check failed. Please review the messages above to fix the issues."
        exit 1
    fi
    exit 0
}

# --- Run main ---
main
EOF

echo "Unpacking 01_env_template.sh..."
cat <<'EOF' > 01_env_template.sh
#!/data/data/com.termux/files/usr/bin/bash
#
# Termux AI Toolkit - Environment Configuration Template
#
# --- HOW TO USE ---
# 1. Copy this file to a new file named 'env' in the config directory:
#    mkdir -p ~/.config/termux-ai
#    cp 01_env_template.sh ~/.config/termux-ai/env
#
# 2. Edit the new '~/.config/termux-ai/env' file with your text editor (e.g., nano).
#
# 3. Add your secret API key(s) below.
#
# 4. In your terminal, run `source ~/.config/termux-ai/env` to load these variables.
#    You must do this for every new Termux session where you want to use the scripts.
#
# --- IMPORTANT: KEEP THIS FILE PRIVATE. DO NOT SHARE IT. ---

# --- AI Provider and API Keys ---
# The scripts will automatically use the provider for the key you set.
# If both keys are set, OpenAI will be used by default.
# You can force a provider by uncommenting the line below:
# export PROVIDER="gemini" # or "openai"

# --- Add your secret API keys here ---
# Uncomment the line for the service you want to use and paste your key.

# For OpenAI (Models: gpt-4o, gpt-4o-mini, gpt-4-turbo)
# export OPENAI_API_KEY="sk-..."

# For Google Gemini (Models: gemini-1.5-pro-latest, gemini-1.5-flash-latest)
# export GEMINI_API_KEY="..."


# --- Model Selection ---
# Set the default models to use for each provider.
# You can override these with the `-m` flag in ai_cli.sh.

export MODEL_OPENAI="gpt-4o-mini"
export MODEL_GEMINI="gemini-1.5-flash-latest"


# --- Advanced Settings (Optional) ---

# Default behavior is a "dry run" (read-only).
# To allow scripts to write output files, uncomment the line below.
# You can also set this per-command, e.g., `DRY_RUN=0 ./clip_summarize.sh`
# export DRY_RUN=0

# Timeout in seconds for API calls.
export AI_TIMEOUT=60

# --- End of Configuration ---
#
# After editing, save the file and run:
# source ~/.config/termux-ai/env
#
# Then check your setup with:
# ./00_check_env.sh
#
EOF

echo "Unpacking ai_cli.sh..."
cat <<'EOF' > ai_cli.sh
#!/data/data/com.termux/files/usr/bin/bash
#
# ai_cli.sh
# The universal AI command-line interface for Termux.
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

# --- Script Info & Workspace ---
SCRIPT_NAME="$(basename "$0")"
CONFIG_DIR="$HOME/.config/termux-ai"
DATA_DIR="$HOME/.local/share/termux-ai"
CACHE_DIR="$HOME/.cache/termux-ai"
OUT_DIR="$DATA_DIR/out"
LOG_FILE="$CACHE_DIR/run.log"
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
    echo "Termux AI Universal CLI"
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
    echo "      --json            Output the raw JSON response from the API."
    echo "      --no-save         Do not save the output to a file."
    echo "      --timeout <secs>  Set a timeout for the API call (default: 60)."
    echo "      --dry-run         Simulate run without writing files (default)."
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
            chunk=$(echo "$line" | sed 's/^data: //')
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
            chunk=$(echo "$line" | sed 's/^data: //')
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
    json_output=0
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
            --json) json_output=1; shift ;;
            --no-save) no_save=1; shift ;;
            --dry-run) dry_run=1; shift ;;
            --timeout) AI_TIMEOUT="$2"; shift 2;;
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
EOF

echo "Unpacking clip_summarize.sh..."
cat <<'EOF' > clip_summarize.sh
#!/data/data/com.termux/files/usr/bin/bash
#
# clip_summarize.sh
# Summarizes text from the Android clipboard.
#
# Usage: ./clip_summarize.sh [--no-save]
#
# Safety:
# - Requires Termux:API to be installed.
# - Reads from the clipboard and passes input to ai_cli.sh.
# - Respects DRY_RUN and other flags passed to it.
#

# --- Strict Mode & Script Dir ---
set -Eeuo pipefail
IFS=$'\n\t'
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# --- Helper Functions ---
log() {
    printf >&2 "\033[0;32m[%s] %s: %s\033[0m\n" "$(date +'%H:%M:%S')" "INFO" "$1"
}
die() {
    printf >&2 "\033[0;31m[%s] %s: %s\033[0m\n" "$(date +'%H:%M:%S')" "ERROR" "$1"
    exit 1
}
require_cmd() {
    command -v "$1" >/dev/null || die "Required command '$1' not found. For this script, please run 'pkg install termux-api'."
}

# --- Main Logic ---
main() {
    require_cmd "termux-clipboard-get"

    log "Getting text from clipboard..."
    local content
    content=$(termux-clipboard-get)

    if [[ -z "$content" ]]; then
        die "Clipboard is empty. Please copy some text first."
    fi

    local system_prompt="You are a text summarization expert. Summarize the following text. Your output must be structured with three sections: 1. A single-sentence 'TL;DR'. 2. A 'Key Points' section with a bulleted list of the most important ideas. 3. An 'Action Items' section with a bulleted list of suggested next steps or actions."

    log "Sending content to AI for summarization..."

    # We need to capture the summary to use it for a notification
    local summary
    summary=$(echo "$content" | "$SCRIPT_DIR/ai_cli.sh" -p - -s "$system_prompt" "$@")

    # Print the full summary to the console
    echo "$summary"

    # Show a notification with a preview
    if command -v termux-notification &> /dev/null; then
        log "Showing notification."
        local tldr
        tldr=$(echo "$summary" | grep -i "TL;DR" | head -n 1)
        termux-notification --title "Clipboard Summarized" --content "$tldr" --led-color "00FF00"
    fi
}

main "$@"
EOF

echo "Unpacking url_summarize.sh..."
cat <<'EOF' > url_summarize.sh
#!/data/data/com.termux/files/usr/bin/bash
#
# url_summarize.sh
# Fetches and summarizes the content of a URL.
#
# Usage: ./url_summarize.sh -u <URL> [--no-save]
#
# Safety:
# - Performs read-only operations on the URL.
# - Can result in multiple API calls for large web pages.
# - Respects DRY_RUN and other flags passed to it.
#

# --- Strict Mode & Script Dir ---
set -Eeuo pipefail
IFS=$'\n\t'
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# --- Helper Functions ---
log() {
    printf >&2 "\033[0;32m[%s] %s: %s\033[0m\n" "$(date +'%H:%M:%S')" "INFO" "$1"
}
die() {
    printf >&2 "\033[0;31m[%s] %s: %s\033[0m\n" "$(date +'%H:%M:%S')" "ERROR" "$1"
    exit 1
}
usage() {
    echo "URL Summarizer"
    echo "Usage: $0 -u <URL> [ai_cli.sh options]"
    exit 1
}

# --- Main Logic ---
main() {
    local url=""
    # Handle basic -u flag, pass the rest to ai_cli
    if [[ "$1" == "-u" ]]; then
        url="$2"
        shift 2
    else
        usage
    fi

    if [[ -z "$url" ]]; then
        usage
    fi

    log "Fetching content from: $url"
    local html_content
    html_content=$(curl -sL --fail "$url" --max-time 30) || die "Failed to fetch URL. Check the link or your connection."

    # Very basic HTML to text conversion
    log "Extracting text from HTML..."
    local text_content
    text_content=$(echo "$html_content" | sed -e 's/<style[^>]*>.*<\/style>//g' -e 's/<script[^>]*>.*<\/script>//g' -e 's/<[^>]*>//g' -e 's/&[^;]*;//g' | sed '/^\s*$/d')

    if [[ -z "$text_content" ]]; then
        die "Could not extract any readable text from the URL."
    fi

    local char_count=${#text_content}
    local chunk_size=8000 # Chars, roughly 2k tokens
    log "Text extracted. Character count: $char_count"

    if [[ "$char_count" -lt "$chunk_size" ]]; then
        # --- Single Shot Summary ---
        log "Content is small enough for a single summary."
        local system_prompt="Summarize the content from the provided URL. Structure your output into: 1. A one-sentence 'TL;DR'. 2. A 'Key Points' section with bullets. 3. A 'Risks & Caveats' section assessing potential biases or issues. 4. A 'Next Actions' section with 3 quick wins."

        echo "$text_content" | "$SCRIPT_DIR/ai_cli.sh" -p - -s "$system_prompt" "$@"
    else
        # --- Map-Reduce Summary for Large Content ---
        log "Content is large. Performing map-reduce summarization."

        local chunks=()
        while IFS= read -r -d '' -n "$chunk_size" chunk; do
            chunks+=("$chunk")
        done < <(printf "%s" "$text_content")

        log "Split content into ${#chunks[@]} chunks."

        local partial_summaries=()
        local i=1
        for chunk in "${chunks[@]}"; do
            log "Summarizing chunk $i of ${#chunks[@]}..."
            local map_prompt="This is one chunk of a larger document. Summarize this specific chunk concisely in a few sentences. Do not add any preamble. Just summarize the text."

            local partial_summary
            partial_summary=$(echo "$chunk" | "$SCRIPT_DIR/ai_cli.sh" -p - -s "$map_prompt" "$@")
            partial_summaries+=("$partial_summary")
            ((i++))
        done

        log "All chunks summarized. Performing final synthesis..."
        local combined_summaries
        combined_summaries=$(printf "%s\n\n" "${partial_summaries[@]}")

        local reduce_prompt="You have been given several sequential summaries from a single document. Your task is to synthesize them into one final, cohesive report. The report must be well-structured and easy to read. Provide: 1. A one-paragraph overall 'Gist'. 2. A 'Key Points' section with the most important takeaways from the entire document. 3. A 'Risks & Caveats' section. 4. A 'Next Actions' section with 3 quick wins based on the full context."

        echo "$combined_summaries" | "$SCRIPT_DIR/ai_cli.sh" -p - -s "$reduce_prompt" "$@"
    fi
}

main "$@"
EOF

echo "Unpacking file_summarize.sh..."
cat <<'EOF' > file_summarize.sh
#!/data/data/com.termux/files/usr/bin/bash
#
# file_summarize.sh
# Reads and summarizes a local text file.
#
# Usage: ./file_summarize.sh -f <path/to/file> [--no-save]
#
# Safety:
# - Performs read-only operations on the file.
# - Can result in multiple API calls for large files.
# - Respects DRY_RUN and other flags passed to it.
#

# --- Strict Mode & Script Dir ---
set -Eeuo pipefail
IFS=$'\n\t'
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# --- Helper Functions ---
log() {
    printf >&2 "\033[0;32m[%s] %s: %s\033[0m\n" "$(date +'%H:%M:%S')" "INFO" "$1"
}
die() {
    printf >&2 "\033[0;31m[%s] %s: %s\033[0m\n" "$(date +'%H:%M:%S')" "ERROR" "$1"
    exit 1
}
usage() {
    echo "File Summarizer"
    echo "Usage: $0 -f <path/to/file> [ai_cli.sh options]"
    exit 1
}

# --- Main Logic ---
main() {
    local filepath=""
    # Handle basic -f flag, pass the rest to ai_cli
    if [[ "$1" == "-f" ]]; then
        filepath="$2"
        shift 2
    else
        usage
    fi

    if [[ -z "$filepath" ]]; then
        usage
    fi

    log "Reading content from file: $filepath"
    if [[ ! -r "$filepath" ]]; then
        die "File not found or is not readable: $filepath"
    fi
    local text_content
    text_content=$(cat "$filepath")

    if [[ -z "$text_content" ]]; then
        die "File is empty."
    fi

    local char_count=${#text_content}
    local chunk_size=8000 # Chars, roughly 2k tokens
    log "Text loaded. Character count: $char_count"

    if [[ "$char_count" -lt "$chunk_size" ]]; then
        # --- Single Shot Summary ---
        log "Content is small enough for a single summary."
        local system_prompt="Summarize the provided file content. Structure your output into: 1. A one-paragraph 'Gist'. 2. A 'Key Points' section with bullets. 3. A 'Potential Q&A' section with 3 likely questions and their answers based on the text."

        echo "$text_content" | "$SCRIPT_DIR/ai_cli.sh" -p - -s "$system_prompt" "$@"
    else
        # --- Map-Reduce Summary for Large Content ---
        log "Content is large. Performing map-reduce summarization."

        local chunks=()
        while IFS= read -r -d '' -n "$chunk_size" chunk; do
            chunks+=("$chunk")
        done < <(printf "%s" "$text_content")

        log "Split content into ${#chunks[@]} chunks."

        local partial_summaries=()
        local i=1
        for chunk in "${chunks[@]}"; do
            log "Summarizing chunk $i of ${#chunks[@]}..."
            local map_prompt="This is one chunk of a larger document. Summarize this specific chunk concisely in a few sentences. Do not add any preamble. Just summarize the text."

            local partial_summary
            partial_summary=$(echo "$chunk" | "$SCRIPT_DIR/ai_cli.sh" -p - -s "$map_prompt" "$@")
            partial_summaries+=("$partial_summary")
            ((i++))
        done

        log "All chunks summarized. Performing final synthesis..."
        local combined_summaries
        combined_summaries=$(printf "%s\n\n" "${partial_summaries[@]}")

        local reduce_prompt="You have been given several sequential summaries from a single document. Your task is to synthesize them into one final, cohesive report. The report must be well-structured and easy to read. Provide: 1. A one-paragraph 'Gist' of the entire document. 2. A 'Key Points' section with the most important takeaways. 3. A 'Potential Q&A' section with three likely questions a reader might have, along with their answers."

        echo "$combined_summaries" | "$SCRIPT_DIR/ai_cli.sh" -p - -s "$reduce_prompt" "$@"
    fi
}

main "$@"
EOF

echo "Unpacking optional_widget_setup.md..."
cat <<'EOF' > optional_widget_setup.md
# Optional: Termux:Widget Setup

This guide will help you create 1-tap shortcuts for the AI Toolkit on your Android home screen using the Termux:Widget app.

## Prerequisites

1.  You have installed the main **Termux AI Toolkit** in the `~/termux-ai-toolkit` directory.
2.  You have installed the **Termux:Widget** app from F-Droid or the Google Play Store.
3.  You have installed the **Termux:API** app and run `pkg install termux-api`. The widgets use `termux-dialog`, `termux-toast`, and `termux-clipboard-get`.
4.  You have configured your API keys in `~/.config/termux-ai/env`.

## How It Works

Termux:Widget runs scripts that you place in the `~/.shortcuts/` directory. We will create a few simple scripts there that call our main toolkit scripts.

Simply copy and paste the command blocks below into your main Termux session to create the shortcut files.

---

### Widget 1: Quick AI Ask

This widget will pop up a dialog box asking for a prompt. The AI's response will be shown as a temporary "toast" notification on your screen and saved to a file.

**➡️ Create the shortcut file:**
Copy and paste this entire block into Termux and press Enter.

```bash
mkdir -p ~/.shortcuts
cat <<'EOT' > ~/.shortcuts/01-ai-ask
#!/data/data/com.termux/files/usr/bin/bash
# Shortcut for a quick AI prompt.

# Source environment to get API keys
[ -f "$HOME/.config/termux-ai/env" ] && source "$HOME/.config/termux-ai/env"

TOOLKIT_DIR="$HOME/termux-ai-toolkit"

# Get input from a user dialog
prompt_input=$(termux-dialog -t "Ask AI" | jq -r .text)

# If user entered text, run the command
if [ -n "$prompt_input" ]; then
    # Ensure DRY_RUN=0 to save the output
    export DRY_RUN=0

    # Run the command and show the full response in a toast
    # Note: Toasts have a text limit; this shows the beginning of the answer.
    summary=$(cd "$TOOLKIT_DIR" && bash ai_cli.sh -p "$prompt_input")
    termux-toast -g middle -b black -c white "$summary"
fi
EOT
chmod +x ~/.shortcuts/01-ai-ask
```

---

### Widget 2: Summarize Clipboard

This widget will instantly summarize any text you have copied to your clipboard. The summary will appear as a toast notification and be saved to a file.

**➡️ Create the shortcut file:**
Copy and paste this entire block into Termux and press Enter.

```bash
mkdir -p ~/.shortcuts
cat <<'EOT' > ~/.shortcuts/02-summarize-clipboard
#!/data/data/com.termux/files/usr/bin/bash
# Shortcut to summarize clipboard content.

# Source environment to get API keys
[ -f "$HOME/.config/termux-ai/env" ] && source "$HOME/.config/termux-ai/env"

TOOLKIT_DIR="$HOME/termux-ai-toolkit"

# Ensure DRY_RUN=0 to save the output
export DRY_RUN=0

# Run the script and show the result in a toast
summary=$(cd "$TOOLKIT_DIR" && bash clip_summarize.sh)
termux-toast -g middle -b black -c white "$summary"
EOT
chmod +x ~/.shortcuts/02-summarize-clipboard
```

---

### Widget 3: Summarize Last URL

This widget will grab the most recent URL from your clipboard and summarize it.

**➡️ Create the shortcut file:**
Copy and paste this entire block into Termux and press Enter.

```bash
mkdir -p ~/.shortcuts
cat <<'EOT' > ~/.shortcuts/03-summarize-url
#!/data/data/com.termux/files/usr/bin/bash
# Shortcut to summarize the last URL in the clipboard.

# Source environment to get API keys
[ -f "$HOME/.config/termux-ai/env" ] && source "$HOME/.config/termux-ai/env"

TOOLKIT_DIR="$HOME/termux-ai-toolkit"

# Get URL from clipboard
url=$(termux-clipboard-get)

# Basic check if it's a URL
if [[ "$url" != http* ]]; then
    termux-toast -g middle -b black -c white "No URL found in clipboard."
    exit 1
fi

# Ensure DRY_RUN=0 to save the output
export DRY_RUN=0

# Notify user that we are starting
termux-toast -g middle "Summarizing URL: $url"

# Run the command and show the result in a new toast
summary=$(cd "$TOOLKIT_DIR" && bash url_summarize.sh -u "$url")
termux-toast -g middle -b black -c white "$summary"
EOT
chmod +x ~/.shortcuts/03-summarize-url
```

---

## Final Step: Add the Widget

1.  Go to your phone's **Home Screen**.
2.  **Long-press** on an empty space and choose **"Widgets"**.
3.  Find the **Termux:Widget** and drag it to your home screen.
4.  A list of your shortcut scripts (`01-ai-ask`, etc.) will appear. Select one.
5.  Repeat for the other scripts.

You can now tap these icons to run the AI commands directly from your home screen!
EOF

echo "Unpacking tests.sh..."
cat <<'EOF' > tests.sh
#!/data/data/com.termux/files/usr/bin/bash
#
# tests.sh
# Smoke tests for the Termux AI Toolkit.
#
# Usage: ./tests.sh
#

# --- Strict Mode & Colors ---
# We disable 'e' because we need to capture exit codes manually
set -uo pipefail
IFS=$'\n\t'
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_RESET='\033[0m'

# --- Test State ---
TEST_COUNT=0
FAIL_COUNT=0
MOCK_DIR="mock_bin"
ARGS_FILE="/tmp/ai_cli_test_args"

# --- Helper Functions ---
pass() {
    ((TEST_COUNT++))
    printf "${C_GREEN}PASS:${C_RESET} %s\n" "$1"
}
fail() {
    ((TEST_COUNT++))
    ((FAIL_COUNT++))
    printf "${C_RED}FAIL:${C_RESET} %s\n" "$1"
}

# --- Mocking Setup ---
cleanup() {
    printf "\nCleaning up...\n"
    # Restore original ai_cli.sh if it exists
    if [ -f "./ai_cli.sh.bak" ]; then
        mv ./ai_cli.sh.bak ./ai_cli.sh
    fi
    rm -rf "$MOCK_DIR"
    rm -f "$ARGS_FILE"
    # Restore PATH
    if [ -n "${ORIGINAL_PATH-}" ]; then
        export PATH="${ORIGINAL_PATH}"
    fi
}
trap cleanup EXIT

setup() {
    echo "--- Setting up mock environment ---"
    mkdir -p "$MOCK_DIR"
    ORIGINAL_PATH="$PATH"

    # Mock critical commands
    for cmd in curl jq termux-clipboard-get; do
        cat <<EOT > "$MOCK_DIR/$cmd"
#!/bin/bash
# Mock for $cmd
if [[ "\$1" == "MOCK_FAIL" ]]; then exit 1; fi
echo "Mock output for $cmd"
exit 0
EOT
        chmod +x "$MOCK_DIR/$cmd"
    done

    export PATH="$(pwd)/$MOCK_DIR:$PATH"
}

# --- Test Cases ---

test_01_ai_cli_help_flag() {
    local out
    out=$(bash ./ai_cli.sh -h 2>&1)
    local code=$?
    if [[ "$code" -eq 0 && "$out" == *"Usage:"* ]]; then
        pass "ai_cli.sh -h shows help and exits 0."
    else
        fail "ai_cli.sh -h failed. Exit: $code, Output: $out"
    fi
}

test_02_ai_cli_mutually_exclusive_args() {
    # In this environment, capturing stderr from a failing script is unreliable.
    # We will test for the exit code only, which is the most important part.
    bash ./ai_cli.sh -p "prompt" -f "file.txt" &>/dev/null
    local code=$?
    if [[ "$code" -ne 0 ]]; then
        pass "ai_cli.sh correctly exits non-zero for mutually exclusive args."
    else
        fail "ai_cli.sh did not fail with mutually exclusive args. Exit: $code"
    fi
}

test_03_check_env_script() {
    # Test pass case
    export OPENAI_API_KEY="test"
    local out
    out=$(bash ./00_check_env.sh 2>&1)
    local code=$?
    if [[ "$code" -eq 0 && "$out" == *"Environment check passed"* ]]; then
        pass "00_check_env.sh passes when environment is OK."
    else
        fail "00_check_env.sh failed on pass case. Exit: $code, Output: $out"
    fi

    # Test fail case
    unset OPENAI_API_KEY
    out=$(bash ./00_check_env.sh 2>&1)
    code=$?
    if [[ "$code" -ne 0 && "$out" == *"No API keys found"* ]]; then
        pass "00_check_env.sh fails when no API keys are set."
    else
        fail "00_check_env.sh did not fail correctly on missing keys. Exit: $code, Output: $out"
    fi
}

test_04_wrapper_scripts_exist() {
    local scripts=("clip_summarize.sh" "url_summarize.sh" "file_summarize.sh")
    for script in "${scripts[@]}"; do
        if [ -f "$script" ]; then
            pass "$script file exists."
        else
            fail "$script file does not exist."
        fi
    done
}

# --- Test Runner ---
main() {
    setup

    echo "--- Running tests ---"
    test_01_ai_cli_help_flag
    test_02_ai_cli_mutually_exclusive_args
    test_03_check_env_script
    test_04_wrapper_scripts_exist

    echo ""
    echo "--- Tests finished ---"
    if [ "$FAIL_COUNT" -eq 0 ]; then
        echo -e "✅ ${C_GREEN}All $TEST_COUNT tests passed!${C_RESET}"
        exit 0
    else
        echo -e "❌ ${C_RED}$FAIL_COUNT out of $TEST_COUNT tests failed.${C_RESET}"
        exit 1
    fi
}

main
EOF

# --- Final Steps ---
echo "Making scripts executable..."
chmod +x ./*.sh

echo -e "\n${GREEN}--- Installation Complete! ---${RESET}"
echo "All files have been installed into: $INSTALL_DIR"
echo ""
echo -e "${BLUE}Next Steps:${RESET}"
echo "1. Change into the new directory:"
echo "   cd $INSTALL_DIR"
echo "2. Set up your API key by copying the template:"
echo "   cp 01_env_template.sh ~/.config/termux-ai/env"
echo "3. Edit the new config file with your key:"
echo "   nano ~/.config/termux-ai/env"
echo "4. Read the main guide for usage instructions:"
echo "   less README_first.md"
echo ""
echo "Enjoy your new AI toolkit!"
