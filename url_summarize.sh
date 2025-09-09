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

# Displays usage information and exits.
usage() {
    echo "URL Summarizer"
    echo "Usage: $0 -u <URL> [ai_cli.sh options]"
    exit 1
}

# --- Main Logic ---

# Main function to fetch and summarize a URL.
# It extracts text from HTML, handles large content by chunking,
# and passes the content to ai_cli.sh for summarization.
#
# Globals:
#   SCRIPT_DIR
# Arguments:
#   $@: The command-line arguments, including the URL.
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
