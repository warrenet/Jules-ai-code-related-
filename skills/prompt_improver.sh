#!/data/data/com.termux/files/usr/bin/bash
#
# prompt_improver.sh
# A skill that improves vague prompts through research and targeted questions.
#
# This skill:
# 1. Creates a research plan (TodoWrite)
# 2. Executes research (codebase, web, docs)
# 3. Generates 1-6 grounded questions for the user
#
# Version: 1.0.0
#

set -Eeuo pipefail
IFS=$'\n\t'

# --- Script Info ---
SCRIPT_NAME="$(basename "$0")"
SKILLS_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SKILLS_DIR/.." && pwd)"

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

# --- Research Planning ---
create_research_plan() {
    local vague_prompt="$1"
    local provider="$2"
    local api_key="$3"
    
    log "INFO" "Creating research plan for vague prompt..."
    
    local plan_prompt="Given this vague user request:
\"$vague_prompt\"

Create a focused research plan to gather context. Output a JSON object with these fields:
{
  \"research_areas\": [\"codebase\", \"web\", \"documentation\"],
  \"key_questions\": [\"question 1\", \"question 2\", ...],
  \"search_terms\": [\"term1\", \"term2\", ...]
}

Be specific and actionable. Focus on gathering the minimum information needed to clarify the request."

    local result=""
    if [[ "$provider" == "openai" ]]; then
        result=$(call_openai_research "$plan_prompt" "$api_key")
    elif [[ "$provider" == "gemini" ]]; then
        result=$(call_gemini_research "$plan_prompt" "$api_key")
    else
        die "Unknown provider: $provider"
    fi
    
    echo "$result"
}

# --- Research Execution ---
execute_research() {
    local plan="$1"
    local project_root="${2:-$PROJECT_ROOT}"
    
    log "INFO" "Executing research plan..."
    
    local research_context=""
    
    # Parse research areas from plan
    local areas
    areas=$(echo "$plan" | jq -r '.research_areas[]?' 2>/dev/null || echo "")
    
    # Research codebase
    if echo "$areas" | grep -q "codebase"; then
        log "INFO" "Researching codebase..."
        local codebase_context
        codebase_context=$(research_codebase "$project_root")
        research_context+="CODEBASE CONTEXT:\n$codebase_context\n\n"
    fi
    
    # Research web (simulated - would use web search API in production)
    if echo "$areas" | grep -q "web"; then
        log "INFO" "Researching web resources..."
        local web_context
        web_context=$(research_web "$plan")
        research_context+="WEB CONTEXT:\n$web_context\n\n"
    fi
    
    # Research documentation
    if echo "$areas" | grep -q "documentation"; then
        log "INFO" "Researching documentation..."
        local docs_context
        docs_context=$(research_documentation "$project_root")
        research_context+="DOCUMENTATION CONTEXT:\n$docs_context\n\n"
    fi
    
    echo "$research_context"
}

research_codebase() {
    local root="$1"
    
    # Get file structure
    local structure
    structure=$(cd "$root" && find . -maxdepth 2 -type f -name "*.sh" -o -name "*.md" 2>/dev/null | head -20)
    
    # Get recent changes
    local recent_changes
    recent_changes=$(cd "$root" && git log --oneline -5 2>/dev/null || echo "No git history available")
    
    cat << CODEBASE
Project structure:
$structure

Recent changes:
$recent_changes
CODEBASE
}

research_web() {
    local plan="$1"
    
    # Extract search terms
    local search_terms
    search_terms=$(echo "$plan" | jq -r '.search_terms[]?' 2>/dev/null || echo "general information")
    
    # In a real implementation, this would use a web search API
    # For now, we simulate with a note
    cat << WEB
Web research would be performed for: $search_terms
(Note: In production, this would use web search APIs or documentation retrieval)
WEB
}

research_documentation() {
    local root="$1"
    
    # Find and extract key documentation snippets
    local docs=""
    
    if [[ -f "$root/README.md" ]]; then
        docs+="README.md (first 20 lines):\n"
        docs+="$(head -20 "$root/README.md")\n\n"
    fi
    
    if [[ -f "$root/ARCHITECTURE.md" ]]; then
        docs+="ARCHITECTURE.md (first 20 lines):\n"
        docs+="$(head -20 "$root/ARCHITECTURE.md")\n\n"
    fi
    
    echo "$docs"
}

# --- Question Generation ---
generate_questions() {
    local vague_prompt="$1"
    local research_context="$2"
    local provider="$3"
    local api_key="$4"
    
    log "INFO" "Generating clarifying questions..."
    
    local question_prompt="Based on this vague user request:
\"$vague_prompt\"

And this research context:
$research_context

Generate 1-6 specific, grounded questions to ask the user to clarify their intent.
Questions should be:
- Specific and actionable
- Based on the actual project context
- Help narrow down the exact task
- Avoid yes/no questions when possible

Output ONLY a JSON array of questions:
[\"question 1\", \"question 2\", ...]"

    local questions=""
    if [[ "$provider" == "openai" ]]; then
        questions=$(call_openai_research "$question_prompt" "$api_key")
    elif [[ "$provider" == "gemini" ]]; then
        questions=$(call_gemini_research "$question_prompt" "$api_key")
    else
        die "Unknown provider: $provider"
    fi
    
    echo "$questions"
}

# --- Provider API calls ---
call_openai_research() {
    local prompt="$1"
    local api_key="$2"
    
    local messages_json
    messages_json=$(jq -n --arg content "$prompt" '[{"role": "user", "content": $content}]')
    
    local payload
    payload=$(jq -n --arg model "gpt-4o-mini" --argjson messages "$messages_json" \
        '{model: $model, messages: $messages, temperature: 0.7}')
    
    local response
    response=$(curl -sS -X POST "https://api.openai.com/v1/chat/completions" \
        -H "Authorization: Bearer $api_key" \
        -H "Content-Type: application/json" \
        --data "$payload" \
        --max-time 60)
    
    echo "$response" | jq -r '.choices[0].message.content'
}

call_gemini_research() {
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
        --max-time 60)
    
    echo "$response" | jq -r '.candidates[0].content.parts[0].text'
}

# --- Main Workflow ---
improve_prompt() {
    local vague_prompt="$1"
    local provider="${2:-openai}"
    local api_key="$3"
    
    if [[ -z "$vague_prompt" ]]; then
        die "Vague prompt is required"
    fi
    
    if [[ -z "$api_key" ]]; then
        die "API key is required"
    fi
    
    # Step 1: Create research plan
    local plan
    plan=$(create_research_plan "$vague_prompt" "$provider" "$api_key")
    
    # Step 2: Execute research
    local context
    context=$(execute_research "$plan" "$PROJECT_ROOT")
    
    # Step 3: Generate questions
    local questions
    questions=$(generate_questions "$vague_prompt" "$context" "$provider" "$api_key")
    
    # Output results
    echo "$questions"
}

# --- CLI Interface ---
usage() {
    echo "Prompt Improver Skill v1.0.0"
    echo ""
    echo "Usage: $SCRIPT_NAME [options]"
    echo ""
    echo "Options:"
    echo "  -p, --prompt <text>      Vague prompt to improve (required)"
    echo "  --provider <name>        AI provider ('openai' or 'gemini', default: openai)"
    echo "  --api-key <key>          API key for the provider (required)"
    echo "  --project-root <path>    Project root for research (default: parent directory)"
    echo "  --help                   Show this help message"
    echo ""
    echo "Output:"
    echo "  JSON array of clarifying questions to ask the user"
    echo ""
    echo "Examples:"
    echo "  $SCRIPT_NAME -p \"fix the bug\" --api-key \$OPENAI_API_KEY"
    echo "  $SCRIPT_NAME -p \"make it better\" --provider gemini --api-key \$GEMINI_API_KEY"
}

main() {
    local prompt=""
    local provider="openai"
    local api_key=""
    local project_root="$PROJECT_ROOT"
    
    # Argument parsing
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -p|--prompt) prompt="$2"; shift 2 ;;
            --provider) provider="$2"; shift 2 ;;
            --api-key) api_key="$2"; shift 2 ;;
            --project-root) project_root="$2"; shift 2 ;;
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
    
    # Improve prompt and output questions
    improve_prompt "$prompt" "$provider" "$api_key"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
