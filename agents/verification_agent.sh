#!/data/data/com.termux/files/usr/bin/bash
# shellcheck disable=SC2154  # AGENT_LOG_DIR, AGENT_STATE_DIR defined in sourced agent_framework.sh
#
# verification_agent.sh
# Verification Agent - Quality assurance and error detection
#
# Version: 1.0.0
#
# Role: Assess implementations for errors, inefficiencies, and issues.
#       Flag problems and suggest improvements.
#

# --- Strict Mode ---
set -Eeuo pipefail
IFS=$'\n\t'

# --- Agent Configuration ---
AGENT_NAME="verification"
AGENT_TYPE="qa"
VERSION="1.0.0"

# --- Load Framework ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=agent_framework.sh
source "$SCRIPT_DIR/agent_framework.sh"

# --- Agent Functions ---

verify_implementation() {
    local task_id="$1"
    local step_number="$2"
    
    agent_log "$AGENT_NAME" "INFO" "Verifying implementation for step $step_number of task $task_id"
    
    # Load implementation
    local implementation
    implementation=$(agent_load_state "implementation" "implementation_${task_id}_step_${step_number}")
    
    if [[ -z "$implementation" ]]; then
        agent_log "$AGENT_NAME" "ERROR" "No implementation found to verify"
        return 1
    fi
    
    agent_create_task "$AGENT_NAME" "verify_${task_id}_${step_number}" "Verify step $step_number"
    
    # Use AI to verify
    local verification_prompt="You are a verification agent. Analyze this implementation for issues:

Implementation:
$implementation

Check for:
1. Logic errors
2. Edge cases not handled
3. Performance issues
4. Security concerns
5. Code quality problems
6. Missing error handling

Provide:
- Issues found (list each with severity: critical/high/medium/low)
- Suggestions for improvement
- Alternative approaches if applicable
- Overall assessment (pass/fail/needs_revision)

Format as JSON with keys: issues, suggestions, alternatives, assessment"
    
    local verification_result
    verification_result=$(echo "$verification_prompt" | bash "$SCRIPT_DIR/../ai_cli.sh" -p - -s "You are an expert verification agent focused on quality and correctness." 2>/dev/null || echo '{"assessment":"error"}')
    
    # Save verification result
    agent_save_state "$AGENT_NAME" "verification_${task_id}_step_${step_number}" "$verification_result"
    
    # Check assessment
    local assessment
    assessment=$(echo "$verification_result" | jq -r '.assessment // "unknown"')
    
    if [[ "$assessment" == "fail" ]] || [[ "$assessment" == "needs_revision" ]]; then
        agent_escalate "$AGENT_NAME" "Implementation failed verification for task $task_id step $step_number"
        agent_send_message "$AGENT_NAME" "implementation" "Verification failed for step $step_number: requires revision"
    else
        agent_log "$AGENT_NAME" "INFO" "Verification passed for step $step_number"
        agent_send_message "$AGENT_NAME" "performance" "Step $step_number verified, ready for audit"
    fi
    
    agent_update_task_status "$AGENT_NAME" "verify_${task_id}_${step_number}" "completed"
    
    echo "$verification_result"
}

verify_full_implementation() {
    local task_id="$1"
    
    agent_log "$AGENT_NAME" "INFO" "Verifying full implementation for task: $task_id"
    
    # Load implementation results
    # shellcheck disable=SC2154  # AGENT_STATE_DIR is defined in agent_framework.sh
    local results_file="$AGENT_STATE_DIR/implementation_results_${task_id}.json"
    
    if [[ ! -f "$results_file" ]]; then
        agent_log "$AGENT_NAME" "ERROR" "No implementation results found"
        return 1
    fi
    
    local steps_count
    steps_count=$(jq -r 'length' "$results_file")
    
    local verification_summary="$AGENT_STATE_DIR/verification_summary_${task_id}.json"
    echo '{"total_steps":0,"verified":0,"failed":0,"critical_issues":0,"high_issues":0}' > "$verification_summary"
    
    # Update total steps
    jq --arg count "$steps_count" '.total_steps = ($count | tonumber)' \
        "$verification_summary" > "${verification_summary}.tmp" && \
        mv "${verification_summary}.tmp" "$verification_summary"
    
    # Verify each step
    for ((i=0; i<steps_count; i++)); do
        local result
        result=$(verify_implementation "$task_id" "$i")
        
        local assessment
        assessment=$(echo "$result" | jq -r '.assessment // "unknown"')
        
        if [[ "$assessment" == "pass" ]]; then
            jq '.verified += 1' "$verification_summary" > "${verification_summary}.tmp" && \
                mv "${verification_summary}.tmp" "$verification_summary"
        else
            jq '.failed += 1' "$verification_summary" > "${verification_summary}.tmp" && \
                mv "${verification_summary}.tmp" "$verification_summary"
        fi
        
        # Count issues by severity
        local critical_count
        critical_count=$(echo "$result" | jq '[.issues[]? | select(.severity == "critical")] | length')
        local high_count
        high_count=$(echo "$result" | jq '[.issues[]? | select(.severity == "high")] | length')
        
        jq --arg crit "$critical_count" --arg high "$high_count" \
            '.critical_issues += ($crit | tonumber) | .high_issues += ($high | tonumber)' \
            "$verification_summary" > "${verification_summary}.tmp" && \
            mv "${verification_summary}.tmp" "$verification_summary"
    done
    
    agent_log "$AGENT_NAME" "INFO" "Full verification complete for task: $task_id"
    
    cat "$verification_summary"
}

check_security() {
    local task_id="$1"
    local step_number="$2"
    
    agent_log "$AGENT_NAME" "INFO" "Performing security check for step $step_number"
    
    local implementation
    implementation=$(agent_load_state "implementation" "implementation_${task_id}_step_${step_number}")
    
    if [[ -z "$implementation" ]]; then
        agent_log "$AGENT_NAME" "ERROR" "No implementation found for security check"
        return 1
    fi
    
    # Security-focused verification
    local security_prompt="Perform a security analysis of this implementation:

$implementation

Check for:
1. Input validation issues
2. Injection vulnerabilities
3. Authentication/authorization flaws
4. Data exposure risks
5. Unsafe operations
6. Cryptographic issues

Provide security assessment with severity levels.
Format as JSON with keys: vulnerabilities, risk_level, recommendations"
    
    local security_result
    security_result=$(echo "$security_prompt" | bash "$SCRIPT_DIR/../ai_cli.sh" -p - -s "You are a security expert analyzing code for vulnerabilities." 2>/dev/null || echo '{"risk_level":"unknown"}')
    
    # Save security assessment
    agent_save_state "$AGENT_NAME" "security_${task_id}_step_${step_number}" "$security_result"
    
    local risk_level
    risk_level=$(echo "$security_result" | jq -r '.risk_level // "unknown"')
    
    if [[ "$risk_level" == "high" ]] || [[ "$risk_level" == "critical" ]]; then
        agent_escalate "$AGENT_NAME" "Security issues found in task $task_id step $step_number (risk: $risk_level)"
    fi
    
    echo "$security_result"
}

get_verification_report() {
    local task_id="$1"
    
    agent_log "$AGENT_NAME" "INFO" "Generating verification report for task: $task_id"
    
    local summary_file="$AGENT_STATE_DIR/verification_summary_${task_id}.json"
    
    if [[ ! -f "$summary_file" ]]; then
        echo "No verification summary available"
        return 1
    fi
    
    local summary
    summary=$(cat "$summary_file")
    
    echo "=== Verification Report for Task: $task_id ==="
    echo "$summary" | jq -r '
        "Total Steps: \(.total_steps)",
        "Verified: \(.verified)",
        "Failed: \(.failed)",
        "Critical Issues: \(.critical_issues)",
        "High Priority Issues: \(.high_issues)"
    '
    
    # Check for escalations
    echo ""
    echo "=== Escalations ==="
    agent_list_escalations | grep -i "$task_id" || echo "None"
}

# --- Main Command Handler ---
usage() {
    echo "Verification Agent v$VERSION"
    echo ""
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  verify <task_id> <step_num>      - Verify a single step"
    echo "  verify-full <task_id>            - Verify entire implementation"
    echo "  security <task_id> <step_num>    - Perform security check"
    echo "  report <task_id>                 - Generate verification report"
    echo "  status <task_id>                 - Check verification status"
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
        verify)
            if [[ $# -lt 2 ]]; then
                echo "Error: verify requires <task_id> <step_num>"
                exit 1
            fi
            verify_implementation "$1" "$2"
            ;;
        verify-full)
            if [[ $# -lt 1 ]]; then
                echo "Error: verify-full requires <task_id>"
                exit 1
            fi
            verify_full_implementation "$1"
            ;;
        security)
            if [[ $# -lt 2 ]]; then
                echo "Error: security requires <task_id> <step_num>"
                exit 1
            fi
            check_security "$1" "$2"
            ;;
        report)
            if [[ $# -lt 1 ]]; then
                echo "Error: report requires <task_id>"
                exit 1
            fi
            get_verification_report "$1"
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
agent_register "$AGENT_NAME" "$AGENT_TYPE" "verification_agent.sh"

# Execute main if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
