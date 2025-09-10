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
    echo "File Summarizer"
    echo "Usage: $0 -f <path/to/file> [ai_cli.sh options]"
    exit 1
}

# --- Main Logic ---

# Main function to read a file, summarize its content using ai_cli.sh,
# and print the summary. Handles large files by chunking.
#
# Globals:
#   SCRIPT_DIR
# Arguments:
#   $@: The command-line arguments, including the file path.
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
