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

# Logs an informational message to stderr.
#
# Arguments:
#   $1: The message to log.
log() {
    printf >&2 "\033[0;32m[%s] %s: %s\033[0m\n" "$(date +'%H:%M:%S')" "INFO" "$1"
}

# Logs an error message to stderr and exits the script.
#
# Arguments:
#   $1: The error message to display.
die() {
    printf >&2 "\033[0;31m[%s] %s: %s\033[0m\n" "$(date +'%H:%M:%S')" "ERROR" "$1"
    exit 1
}

# Checks if a command exists and exits if it doesn't.
#
# Arguments:
#   $1: The command name to check.
require_cmd() {
    command -v "$1" >/dev/null || die "Required command '$1' not found. For this script, please run 'pkg install termux-api'."
}

# --- Main Logic ---

# Main function to get clipboard content, summarize it via ai_cli.sh,
# and display the result.
#
# Globals:
#   SCRIPT_DIR
# Arguments:
#   $@: remaining arguments passed to ai_cli.sh
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
