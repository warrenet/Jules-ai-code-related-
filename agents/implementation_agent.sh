#!/data/data/com.termux/files/usr/bin/bash
#
# implementation_agent.sh
# Implementation Agent - Solution development and execution
#
# Version: 1.0.0
#
# Role: Develop solutions based on execution plans, document reasoning,
#       and implement with clear assumptions and logic.
#

# --- Strict Mode ---
set -Eeuo pipefail
IFS=$'\n\t'

# --- Agent Configuration ---
AGENT_NAME="implementation"
AGENT_TYPE="builder"
VERSION="1.0.0"

# --- Load Framework ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=agent_framework.sh
source "$SCRIPT_DIR/agent_framework.sh"

# --- Agent Functions ---

implement_step() {
    local task_id="$1"
    local step_number="$2"
    local step_description="$3"
    
    agent_log "$AGENT_NAME" "INFO" "Implementing step $step_number: $step_description"
    
    local start_time
    start_time=$(date +%s)
    
    # Create implementation task
    agent_create_task "$AGENT_NAME" "${task_id}_step_${step_number}" "Implement: $step_description"
    
    # Use AI to generate implementation
    local implementation_prompt="You are an implementation agent. Develop a solution for this step:

Step: $step_description

Provide:
1. Implementation approach
2. Code/commands needed
3. Assumptions made
4. Edge cases considered
5. Expected outcomes
6. Testing approach

Format as JSON with keys: approach, code, assumptions, edge_cases, outcomes, testing"
    
    local ai_output
    ai_output=$(echo "$implementation_prompt" | bash "$SCRIPT_DIR/../ai_cli.sh" -p - -s "You are an expert implementation agent focused on building reliable solutions." 2>/dev/null || echo '{}')
    
    # Save implementation
    agent_save_state "$AGENT_NAME" "implementation_${task_id}_step_${step_number}" "$ai_output"
    agent_update_task_status "$AGENT_NAME" "${task_id}_step_${step_number}" "completed"
    
    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Record metrics
    agent_record_metric "$AGENT_NAME" "implementation_time" "$duration"
    
    agent_log "$AGENT_NAME" "INFO" "Step $step_number completed in ${duration}s"
    
    # Send to verification agent
    agent_send_message "$AGENT_NAME" "verification" "Implementation ready for step $step_number of task $task_id"
    
    echo "$ai_output"
}

implement_full_plan() {
    local task_id="$1"
    
    agent_log "$AGENT_NAME" "INFO" "Implementing full plan for task: $task_id"
    
    # Load execution plan
    local plan_file="$AGENT_STATE_DIR/execution_plan_${task_id}.json"
    
    if [[ ! -f "$plan_file" ]]; then
        agent_log "$AGENT_NAME" "ERROR" "No execution plan found for task: $task_id"
        return 1
    fi
    
    local steps_count
    steps_count=$(jq -r '.steps | length' "$plan_file")
    
    agent_log "$AGENT_NAME" "INFO" "Found $steps_count steps to implement"
    
    local results_file="$AGENT_STATE_DIR/implementation_results_${task_id}.json"
    echo "[]" > "$results_file"
    
    # Implement each step
    for ((i=0; i<steps_count; i++)); do
        local step_desc
        step_desc=$(jq -r ".steps[$i]" "$plan_file")
        
        local result
        result=$(implement_step "$task_id" "$i" "$step_desc")
        
        # Append to results
        jq --argjson step "$i" --argjson result "$result" \
            '. += [{step: $step, result: $result}]' \
            "$results_file" > "${results_file}.tmp" && \
            mv "${results_file}.tmp" "$results_file"
    done
    
    agent_log "$AGENT_NAME" "INFO" "All steps implemented for task: $task_id"
    
    cat "$results_file"
}

document_implementation() {
    local task_id="$1"
    local step_number="$2"
    
    agent_log "$AGENT_NAME" "INFO" "Documenting implementation for step $step_number"
    
    local implementation
    implementation=$(agent_load_state "$AGENT_NAME" "implementation_${task_id}_step_${step_number}")
    
    if [[ -z "$implementation" ]]; then
        agent_log "$AGENT_NAME" "ERROR" "No implementation found"
        return 1
    fi
    
    # Extract and format documentation
    local doc_prompt="Create clear documentation for this implementation:

$implementation

Include:
1. What was implemented
2. Why this approach was chosen
3. How to use it
4. Limitations and considerations

Format as markdown."
    
    local documentation
    documentation=$(echo "$doc_prompt" | bash "$SCRIPT_DIR/../ai_cli.sh" -p - -s "You are a technical writer creating implementation documentation." 2>/dev/null || echo "# Documentation unavailable")
    
    # Save documentation
    local doc_file="$AGENT_STATE_DIR/documentation_${task_id}_step_${step_number}.md"
    echo "$documentation" > "$doc_file"
    
    agent_log "$AGENT_NAME" "INFO" "Documentation saved: $doc_file"
    
    echo "$documentation"
}

get_implementation_metrics() {
    agent_log "$AGENT_NAME" "INFO" "Retrieving implementation metrics"
    
    local metrics
    metrics=$(agent_get_metrics "$AGENT_NAME" "implementation_time")
    
    # Calculate statistics
    local count
    local total
    local avg
    
    count=$(echo "$metrics" | jq 'length')
    
    if [[ "$count" -gt 0 ]]; then
        total=$(echo "$metrics" | jq '[.[].value | tonumber] | add')
        avg=$(echo "$metrics" | jq '[.[].value | tonumber] | add / length')
        
        echo "Implementation Metrics:"
        echo "  Total implementations: $count"
        echo "  Total time: ${total}s"
        echo "  Average time: ${avg}s"
    else
        echo "No metrics available"
    fi
}

# --- Main Command Handler ---
usage() {
    echo "Implementation Agent v$VERSION"
    echo ""
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  step <task_id> <step_num> <description>  - Implement a single step"
    echo "  full <task_id>                           - Implement full plan"
    echo "  document <task_id> <step_num>            - Document implementation"
    echo "  metrics                                  - Show implementation metrics"
    echo "  status <task_id>                         - Check task status"
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
        step)
            if [[ $# -lt 3 ]]; then
                echo "Error: step requires <task_id> <step_num> <description>"
                exit 1
            fi
            implement_step "$1" "$2" "$3"
            ;;
        full)
            if [[ $# -lt 1 ]]; then
                echo "Error: full requires <task_id>"
                exit 1
            fi
            implement_full_plan "$1"
            ;;
        document)
            if [[ $# -lt 2 ]]; then
                echo "Error: document requires <task_id> <step_num>"
                exit 1
            fi
            document_implementation "$1" "$2"
            ;;
        metrics)
            get_implementation_metrics
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
agent_register "$AGENT_NAME" "$AGENT_TYPE" "implementation_agent.sh"

# Execute main if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
