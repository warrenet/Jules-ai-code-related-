#!/data/data/com.termux/files/usr/bin/bash
# shellcheck disable=SC2154  # AGENT_LOG_DIR, AGENT_STATE_DIR defined in sourced agent_framework.sh
#
# research_agent.sh
# Research and Planning Agent - Problem decomposition and planning
#
# Version: 1.0.0
#
# Role: Break down complex problems into manageable pieces, identify dependencies,
#       and gather necessary context for successful implementation.
#

# --- Strict Mode ---
set -Eeuo pipefail
IFS=$'\n\t'

# --- Agent Configuration ---
AGENT_NAME="research"
AGENT_TYPE="planning"
VERSION="1.0.0"

# --- Load Framework ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=agent_framework.sh
source "$SCRIPT_DIR/agent_framework.sh"

# --- Agent Functions ---

decompose_problem() {
    local problem="$1"
    local task_id="$2"
    
    agent_log "$AGENT_NAME" "INFO" "Decomposing problem: $problem"
    agent_create_task "$AGENT_NAME" "$task_id" "Decompose: $problem"
    
    # Use AI to decompose the problem
    local decomposition_prompt="You are a research and planning agent. Break down this problem into clear, actionable steps:

Problem: $problem

Provide:
1. Main objective
2. Prerequisites and dependencies
3. Step-by-step breakdown
4. Potential challenges
5. Questions that need clarification

Format as JSON with keys: objective, prerequisites, steps, challenges, clarifications"
    
    # Call the AI CLI to get decomposition
    local ai_output
    ai_output=$(echo "$decomposition_prompt" | bash "$SCRIPT_DIR/../ai_cli.sh" -p - -s "You are an expert planning agent focused on problem decomposition." 2>/dev/null || echo '{}')
    
    # Save decomposition
    agent_save_state "$AGENT_NAME" "decomposition_${task_id}" "$ai_output"
    agent_update_task_status "$AGENT_NAME" "$task_id" "completed"
    
    echo "$ai_output"
}

identify_dependencies() {
    local task_id="$1"
    
    agent_log "$AGENT_NAME" "INFO" "Identifying dependencies for task: $task_id"
    
    # Load decomposition from state
    local decomposition
    decomposition=$(agent_load_state "$AGENT_NAME" "decomposition_${task_id}")
    
    if [[ -z "$decomposition" ]]; then
        agent_log "$AGENT_NAME" "ERROR" "No decomposition found for task: $task_id"
        return 1
    fi
    
    # Extract prerequisites using jq
    local prerequisites
    prerequisites=$(echo "$decomposition" | jq -r '.prerequisites // "None identified"' 2>/dev/null || echo "None identified")
    
    agent_log "$AGENT_NAME" "INFO" "Dependencies identified: $prerequisites"
    echo "$prerequisites"
}

generate_clarifications() {
    local task_id="$1"
    
    agent_log "$AGENT_NAME" "INFO" "Generating clarification questions for task: $task_id"
    
    # Load decomposition from state
    local decomposition
    decomposition=$(agent_load_state "$AGENT_NAME" "decomposition_${task_id}")
    
    if [[ -z "$decomposition" ]]; then
        agent_log "$AGENT_NAME" "ERROR" "No decomposition found for task: $task_id"
        return 1
    fi
    
    # Extract clarifications
    local clarifications
    clarifications=$(echo "$decomposition" | jq -r '.clarifications // []' 2>/dev/null || echo "[]")
    
    echo "$clarifications"
}

create_execution_plan() {
    local task_id="$1"
    
    agent_log "$AGENT_NAME" "INFO" "Creating execution plan for task: $task_id"
    
    # Load decomposition
    local decomposition
    decomposition=$(agent_load_state "$AGENT_NAME" "decomposition_${task_id}")
    
    if [[ -z "$decomposition" ]]; then
        agent_log "$AGENT_NAME" "ERROR" "No decomposition found for task: $task_id"
        return 1
    fi
    
    # Extract steps and create execution plan
    local steps
    steps=$(echo "$decomposition" | jq -r '.steps // []' 2>/dev/null || echo "[]")
    
    local plan_file="$AGENT_STATE_DIR/execution_plan_${task_id}.json"
    jq -n \
        --arg task_id "$task_id" \
        --argjson steps "$steps" \
        --arg created "$(date -Iseconds)" \
        '{task_id: $task_id, steps: $steps, created: $created, status: "pending"}' \
        > "$plan_file"
    
    agent_log "$AGENT_NAME" "INFO" "Execution plan created: $plan_file"
    
    # Send message to implementation agent
    agent_send_message "$AGENT_NAME" "implementation" "Execution plan ready for task: $task_id"
    
    echo "$steps"
}

# --- Main Command Handler ---
usage() {
    echo "Research Agent v$VERSION"
    echo ""
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  decompose <problem> <task_id>  - Break down a problem"
    echo "  dependencies <task_id>         - Identify dependencies"
    echo "  clarify <task_id>              - Generate clarification questions"
    echo "  plan <task_id>                 - Create execution plan"
    echo "  status <task_id>               - Check task status"
    echo ""
}

main() {
    if [[ $# -eq 0 ]]; then
        usage
        exit 1
    fi
    
    local command="$1"
    shift
    
    case "$command" in
        decompose)
            if [[ $# -lt 2 ]]; then
                echo "Error: decompose requires <problem> <task_id>"
                exit 1
            fi
            decompose_problem "$1" "$2"
            ;;
        dependencies)
            if [[ $# -lt 1 ]]; then
                echo "Error: dependencies requires <task_id>"
                exit 1
            fi
            identify_dependencies "$1"
            ;;
        clarify)
            if [[ $# -lt 1 ]]; then
                echo "Error: clarify requires <task_id>"
                exit 1
            fi
            generate_clarifications "$1"
            ;;
        plan)
            if [[ $# -lt 1 ]]; then
                echo "Error: plan requires <task_id>"
                exit 1
            fi
            create_execution_plan "$1"
            ;;
        status)
            if [[ $# -lt 1 ]]; then
                echo "Error: status requires <task_id>"
                exit 1
            fi
            agent_get_task_status "$AGENT_NAME" "$1"
            ;;
        *)
            echo "Unknown command: $command"
            usage
            exit 1
            ;;
    esac
}

# Register this agent
agent_register "$AGENT_NAME" "$AGENT_TYPE" "research_agent.sh"

# Execute main if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
