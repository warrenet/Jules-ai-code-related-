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

# Logs a message with a status level (OK, WARN, FAIL, INFO).
#
# Globals:
#   C_GREEN, C_YELLOW, C_RED, C_BLUE, C_RESET
# Arguments:
#   $1: The status level.
#   $2: The message to log.
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

# Main function to check for dependencies, internet connectivity, and API keys.
# It reports the status of each check and exits with a non-zero status if
# critical components are missing.
#
# Globals:
#   OPENAI_API_KEY, GEMINI_API_KEY
# Arguments:
#   None
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
