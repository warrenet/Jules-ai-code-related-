#!/data/data/com.termux/files/usr/bin/bash
#
# workflow_orchestrator.sh
# Workflow Orchestrator - Multi-agent coordination and execution
#
# Version: 1.0.0
#
# Role: Coordinate multiple agents to solve complex problems through
#       decomposition, implementation, verification, and continuous improvement.
#

# --- Strict Mode ---
set -Eeuo pipefail
IFS=$'\n\t'

# --- Orchestrator Configuration ---
ORCHESTRATOR_VERSION="1.0.0"

# --- Load Framework ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=agent_framework.sh
source "$SCRIPT_DIR/agent_framework.sh"

# Make all agent scripts executable
chmod +x "$SCRIPT_DIR"/*.sh 2>/dev/null || true

# --- Workflow Functions ---

execute_full_workflow() {
    local problem="$1"
    local task_id="$2"
    
    agent_log "orchestrator" "INFO" "Starting full workflow for problem: $problem"
    agent_log "orchestrator" "INFO" "Task ID: $task_id"
    
    echo "=== Multi-Agent Workflow Execution ==="
    echo "Problem: $problem"
    echo "Task ID: $task_id"
    echo ""
    
    # Phase 1: Research & Planning
    echo "Phase 1: Research & Planning"
    echo "----------------------------"
    agent_log "orchestrator" "INFO" "Phase 1: Running research agent"
    
    local decomposition
    # shellcheck disable=SC2034  # Variable captures output for error checking
    decomposition=$(bash "$SCRIPT_DIR/research_agent.sh" decompose "$problem" "$task_id")
    
    echo "Problem decomposed successfully"
    echo ""
    
    # Check for clarifications
    local clarifications
    clarifications=$(bash "$SCRIPT_DIR/research_agent.sh" clarify "$task_id")
    
    if [[ "$clarifications" != "[]" ]] && [[ "$clarifications" != "" ]]; then
        echo "Clarifications needed:"
        echo "$clarifications" | jq -r '.[] // empty'
        echo ""
    fi
    
    # Generate execution plan
    echo "Creating execution plan..."
    bash "$SCRIPT_DIR/research_agent.sh" plan "$task_id" > /dev/null
    echo "Execution plan created"
    echo ""
    
    # Phase 2: Implementation
    echo "Phase 2: Implementation"
    echo "----------------------"
    agent_log "orchestrator" "INFO" "Phase 2: Running implementation agent"
    
    local impl_results
    # shellcheck disable=SC2034  # Variable captures output for error checking
    impl_results=$(bash "$SCRIPT_DIR/implementation_agent.sh" full "$task_id")
    
    echo "Implementation completed"
    echo ""
    
    # Phase 3: Verification
    echo "Phase 3: Verification"
    echo "--------------------"
    agent_log "orchestrator" "INFO" "Phase 3: Running verification agent"
    
    local verification_summary
    verification_summary=$(bash "$SCRIPT_DIR/verification_agent.sh" verify-full "$task_id")
    
    echo "Verification Summary:"
    echo "$verification_summary" | jq -r '
        "  Total Steps: \(.total_steps)",
        "  Verified: \(.verified)",
        "  Failed: \(.failed)",
        "  Critical Issues: \(.critical_issues)",
        "  High Priority Issues: \(.high_issues)"
    '
    echo ""
    
    # Check for failures and trigger recovery if needed
    local failed_count
    failed_count=$(echo "$verification_summary" | jq -r '.failed')
    
    if [[ "$failed_count" -gt 0 ]]; then
        echo "⚠ Verification failures detected, running anomaly detection..."
        bash "$SCRIPT_DIR/anomaly_detection_agent.sh" scan "$task_id" > /dev/null
        echo ""
    fi
    
    # Phase 4: Performance Audit
    echo "Phase 4: Performance Audit"
    echo "-------------------------"
    agent_log "orchestrator" "INFO" "Phase 4: Running performance auditor"
    
    bash "$SCRIPT_DIR/performance_auditor.sh" audit "$task_id" > /dev/null
    bash "$SCRIPT_DIR/performance_auditor.sh" ethics "$task_id" > /dev/null
    bash "$SCRIPT_DIR/performance_auditor.sh" cost "$task_id" > /dev/null
    
    local comprehensive_report
    comprehensive_report=$(bash "$SCRIPT_DIR/performance_auditor.sh" report "$task_id")
    
    echo "Performance Report:"
    echo "$comprehensive_report" | jq -r '
        "  Total Time: \(.performance.metrics.total_time_seconds)s",
        "  Average Time: \(.performance.metrics.average_time_seconds)s",
        "  Estimated Cost: $\(.cost.estimated_cost_usd)",
        "  Ethics Compliance: \(.ethics.compliance)"
    ' 2>/dev/null || echo "  Report generation in progress..."
    echo ""
    
    # Phase 5: Final Summary
    echo "Phase 5: Workflow Complete"
    echo "-------------------------"
    agent_log "orchestrator" "INFO" "Workflow execution completed"
    
    # Generate final summary
    local summary_file="$AGENT_STATE_DIR/workflow_summary_${task_id}.json"
    jq -n \
        --arg task_id "$task_id" \
        --arg problem "$problem" \
        --argjson verification "$verification_summary" \
        --argjson performance "$comprehensive_report" \
        --arg completed_at "$(date -Iseconds)" \
        '{
            task_id: $task_id,
            problem: $problem,
            verification: $verification,
            performance: $performance,
            completed_at: $completed_at,
            status: "completed"
        }' > "$summary_file"
    
    echo "✓ Workflow completed successfully"
    echo "Summary saved to: $summary_file"
    echo ""
    
    cat "$summary_file"
}

execute_interactive_workflow() {
    local problem="$1"
    
    agent_log "orchestrator" "INFO" "Starting interactive workflow"
    
    # Generate task ID
    local task_id
    task_id="task_$(date +%s)"
    
    echo "=== Interactive Multi-Agent Workflow ==="
    echo "Problem: $problem"
    echo "Task ID: $task_id"
    echo ""
    
    # Phase 1: Research
    echo "Running research agent..."
    bash "$SCRIPT_DIR/research_agent.sh" decompose "$problem" "$task_id"
    
    # Ask for user confirmation
    echo ""
    echo "Review the decomposition above. Continue? (y/n)"
    read -r response
    
    if [[ "$response" != "y" ]]; then
        echo "Workflow cancelled by user"
        return 1
    fi
    
    # Generate plan
    bash "$SCRIPT_DIR/research_agent.sh" plan "$task_id" > /dev/null
    
    # Phase 2: Implementation
    echo ""
    echo "Running implementation agent..."
    bash "$SCRIPT_DIR/implementation_agent.sh" full "$task_id"
    
    # Ask for user confirmation
    echo ""
    echo "Implementation complete. Run verification? (y/n)"
    read -r response
    
    if [[ "$response" != "y" ]]; then
        echo "Skipping verification"
    else
        # Phase 3: Verification
        echo ""
        echo "Running verification agent..."
        bash "$SCRIPT_DIR/verification_agent.sh" verify-full "$task_id"
        
        echo ""
        echo "Verification complete. Run performance audit? (y/n)"
        read -r response
        
        if [[ "$response" == "y" ]]; then
            # Phase 4: Performance Audit
            echo ""
            echo "Running performance auditor..."
            bash "$SCRIPT_DIR/performance_auditor.sh" audit "$task_id"
            bash "$SCRIPT_DIR/performance_auditor.sh" report "$task_id"
        fi
    fi
    
    echo ""
    echo "✓ Interactive workflow completed"
    echo "Task ID: $task_id"
}

list_workflows() {
    agent_log "orchestrator" "INFO" "Listing all workflows"
    
    echo "=== Active Workflows ==="
    echo ""
    
    local summary_files=("$AGENT_STATE_DIR"/workflow_summary_*.json)
    
    if [[ ! -f "${summary_files[0]}" ]]; then
        echo "No workflows found"
        return 0
    fi
    
    for summary_file in "${summary_files[@]}"; do
        if [[ -f "$summary_file" ]]; then
            local task_id
            local problem
            local status
            local completed_at
            
            task_id=$(jq -r '.task_id' "$summary_file")
            problem=$(jq -r '.problem' "$summary_file")
            status=$(jq -r '.status' "$summary_file")
            completed_at=$(jq -r '.completed_at' "$summary_file")
            
            echo "Task ID: $task_id"
            echo "  Problem: $problem"
            echo "  Status: $status"
            echo "  Completed: $completed_at"
            echo ""
        fi
    done
}

get_workflow_status() {
    local task_id="$1"
    
    agent_log "orchestrator" "INFO" "Getting status for workflow: $task_id"
    
    local summary_file="$AGENT_STATE_DIR/workflow_summary_${task_id}.json"
    
    if [[ ! -f "$summary_file" ]]; then
        echo "Workflow not found: $task_id"
        return 1
    fi
    
    echo "=== Workflow Status: $task_id ==="
    cat "$summary_file" | jq '.'
}

cleanup_workflow() {
    local task_id="$1"
    
    agent_log "orchestrator" "INFO" "Cleaning up workflow: $task_id"
    
    echo "Removing workflow data for: $task_id"
    
    # Remove all related files
    rm -f "$AGENT_STATE_DIR"/workflow_summary_"${task_id}".json
    rm -f "$AGENT_STATE_DIR"/execution_plan_"${task_id}".json
    rm -f "$AGENT_STATE_DIR"/implementation_results_"${task_id}".json
    rm -f "$AGENT_STATE_DIR"/verification_summary_"${task_id}".json
    rm -f "$AGENT_STATE_DIR"/comprehensive_audit_"${task_id}".json
    rm -f "$AGENT_STATE_DIR"/anomaly_report_"${task_id}".json
    rm -f "$AGENT_STATE_DIR"/task_*_"${task_id}"*.json
    
    echo "✓ Workflow data cleaned"
}

# --- Main Command Handler ---
usage() {
    echo "Multi-Agent Workflow Orchestrator v$ORCHESTRATOR_VERSION"
    echo ""
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  run <problem> <task_id>     - Execute full automated workflow"
    echo "  interactive <problem>       - Execute interactive workflow with user prompts"
    echo "  list                        - List all workflows"
    echo "  status <task_id>            - Get workflow status"
    echo "  cleanup <task_id>           - Clean up workflow data"
    echo "  health                      - Check system health"
    echo ""
    echo "Examples:"
    echo "  $0 run 'Create a web scraper' task_001"
    echo "  $0 interactive 'Optimize database queries'"
    echo "  $0 status task_001"
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
        run)
            if [[ $# -lt 2 ]]; then
                echo "Error: run requires <problem> <task_id>"
                exit 1
            fi
            execute_full_workflow "$1" "$2"
            ;;
        interactive)
            if [[ $# -lt 1 ]]; then
                echo "Error: interactive requires <problem>"
                exit 1
            fi
            execute_interactive_workflow "$1"
            ;;
        list)
            list_workflows
            ;;
        status)
            if [[ $# -lt 1 ]]; then
                echo "Error: status requires <task_id>"
                exit 1
            fi
            get_workflow_status "$1"
            ;;
        cleanup)
            if [[ $# -lt 1 ]]; then
                echo "Error: cleanup requires <task_id>"
                exit 1
            fi
            cleanup_workflow "$1"
            ;;
        health)
            bash "$SCRIPT_DIR/anomaly_detection_agent.sh" health
            ;;
        *)
            echo "Unknown command: $command"
            usage
            exit 1
            ;;
    esac
}

agent_log "orchestrator" "INFO" "Workflow Orchestrator v$ORCHESTRATOR_VERSION initialized"

# Execute main if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
