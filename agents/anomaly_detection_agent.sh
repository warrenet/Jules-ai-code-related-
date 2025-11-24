#!/data/data/com.termux/files/usr/bin/bash
# shellcheck disable=SC2154  # AGENT_LOG_DIR, AGENT_STATE_DIR defined in sourced agent_framework.sh
#
# anomaly_detection_agent.sh
# Anomaly Detection Agent - Error detection and self-healing
#
# Version: 1.0.0
#
# Role: Scan for unexpected outputs, failures in reasoning, bottlenecks.
#       Trigger automated recovery and log issues for learning.
#

# --- Strict Mode ---
set -Eeuo pipefail
IFS=$'\n\t'

# --- Agent Configuration ---
AGENT_NAME="anomaly"
AGENT_TYPE="monitor"
VERSION="1.0.0"

# --- Load Framework ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=agent_framework.sh
source "$SCRIPT_DIR/agent_framework.sh"

# --- Agent Functions ---

scan_for_anomalies() {
    local task_id="$1"
    
    agent_log "$AGENT_NAME" "INFO" "Scanning for anomalies in task: $task_id"
    
    local anomalies=()
    local anomaly_count=0
    
    # Check for failed tasks
    local task_files=("$AGENT_STATE_DIR"/task_*_"${task_id}"*.json)
    for task_file in "${task_files[@]}"; do
        if [[ -f "$task_file" ]]; then
            local status
            status=$(jq -r '.status // "unknown"' "$task_file")
            
            if [[ "$status" == "failed" ]] || [[ "$status" == "error" ]]; then
                anomalies+=("Task failure detected: $(basename "$task_file")")
                ((anomaly_count++))
                agent_log "$AGENT_NAME" "WARN" "Anomaly: Failed task in $task_file"
            fi
        fi
    done
    
    # Check for unusual execution times
    local metrics
    metrics=$(agent_get_metrics "implementation" "implementation_time")
    
    if [[ -n "$metrics" ]] && [[ "$metrics" != "[]" ]]; then
        local avg_time
        avg_time=$(echo "$metrics" | jq '[.[].value | tonumber] | add / length')
        
        local threshold
        threshold=$(echo "$avg_time * 3" | bc)
        
        # Check for outliers
        while IFS= read -r metric; do
            if [[ -n "$metric" ]]; then
                local value
                value=$(echo "$metric" | jq -r '.value // "0"')
                
                if (( $(echo "$value > $threshold" | bc -l) )); then
                    anomalies+=("Unusual execution time: ${value}s (threshold: ${threshold}s)")
                    ((anomaly_count++))
                    agent_log "$AGENT_NAME" "WARN" "Anomaly: Execution time ${value}s exceeds threshold"
                fi
            fi
        done < <(echo "$metrics" | jq -c '.[]')
    fi
    
    # Check for escalations
    local escalation_files=("$AGENT_STATE_DIR"/escalation_*.json)
    for esc_file in "${escalation_files[@]}"; do
        if [[ -f "$esc_file" ]]; then
            local esc_status
            esc_status=$(jq -r '.status // "unknown"' "$esc_file")
            
            if [[ "$esc_status" == "open" ]]; then
                local issue
                issue=$(jq -r '.issue // "unknown"' "$esc_file")
                anomalies+=("Open escalation: $issue")
                ((anomaly_count++))
            fi
        fi
    done
    
    # Create anomaly report
    local report_file="$AGENT_STATE_DIR/anomaly_report_${task_id}.json"
    printf '%s\n' "${anomalies[@]}" | jq -R . | jq -s \
        --arg task_id "$task_id" \
        --arg count "$anomaly_count" \
        '{
            task_id: $task_id,
            anomaly_count: ($count | tonumber),
            anomalies: .,
            scan_timestamp: (now | todate)
        }' > "$report_file"
    
    agent_log "$AGENT_NAME" "INFO" "Anomaly scan complete: $anomaly_count anomalies found"
    
    if [[ $anomaly_count -gt 0 ]]; then
        agent_record_metric "$AGENT_NAME" "anomalies_detected" "$anomaly_count"
    fi
    
    cat "$report_file"
}

trigger_recovery() {
    local task_id="$1"
    local step_number="$2"
    local recovery_action="${3:-retry}"
    
    agent_log "$AGENT_NAME" "INFO" "Triggering recovery for task $task_id step $step_number: $recovery_action"
    
    case "$recovery_action" in
        retry)
            agent_log "$AGENT_NAME" "INFO" "Attempting to retry step $step_number"
            
            # Load original step description
            local plan_file="$AGENT_STATE_DIR/execution_plan_${task_id}.json"
            if [[ -f "$plan_file" ]]; then
                local step_desc
                step_desc=$(jq -r ".steps[$step_number]" "$plan_file")
                
                # Send message to implementation agent to retry
                agent_send_message "$AGENT_NAME" "implementation" "Retry request for step $step_number: $step_desc"
                
                agent_log "$AGENT_NAME" "INFO" "Recovery action sent to implementation agent"
            else
                agent_log "$AGENT_NAME" "ERROR" "Cannot retry: execution plan not found"
                return 1
            fi
            ;;
        fallback)
            agent_log "$AGENT_NAME" "INFO" "Executing fallback for step $step_number"
            
            # Create fallback task
            agent_create_task "$AGENT_NAME" "fallback_${task_id}_${step_number}" "Fallback for failed step"
            
            # Send to research agent for alternative approach
            agent_send_message "$AGENT_NAME" "research" "Need alternative approach for task $task_id step $step_number"
            
            agent_log "$AGENT_NAME" "INFO" "Fallback initiated"
            ;;
        escalate)
            agent_log "$AGENT_NAME" "WARN" "Escalating issue for step $step_number"
            agent_escalate "$AGENT_NAME" "Recovery failed for task $task_id step $step_number"
            ;;
        *)
            agent_log "$AGENT_NAME" "ERROR" "Unknown recovery action: $recovery_action"
            return 1
            ;;
    esac
    
    # Log recovery attempt
    agent_record_metric "$AGENT_NAME" "recovery_attempts" "1"
}

monitor_health() {
    agent_log "$AGENT_NAME" "INFO" "Monitoring system health"
    
    local health_report=()
    local health_score=100
    
    # Check log sizes
    local log_dir_size
    # shellcheck disable=SC2154  # AGENT_LOG_DIR is defined in agent_framework.sh
    log_dir_size=$(du -sh "$AGENT_LOG_DIR" 2>/dev/null | cut -f1 || echo "0")
    health_report+=("Log directory size: $log_dir_size")
    
    # Check state directory
    local state_dir_size
    # shellcheck disable=SC2154  # AGENT_STATE_DIR is defined in agent_framework.sh
    state_dir_size=$(du -sh "$AGENT_STATE_DIR" 2>/dev/null | cut -f1 || echo "0")
    health_report+=("State directory size: $state_dir_size")
    
    # Check for stale tasks (older than 24 hours)
    local stale_count=0
    local task_files=("$AGENT_STATE_DIR"/task_*.json)
    local current_time
    current_time=$(date +%s)
    
    for task_file in "${task_files[@]}"; do
        if [[ -f "$task_file" ]]; then
            local created
            created=$(jq -r '.created // ""' "$task_file")
            
            if [[ -n "$created" ]]; then
                local created_ts
                created_ts=$(date -d "$created" +%s 2>/dev/null || echo "0")
                local age=$((current_time - created_ts))
                
                if [[ $age -gt 86400 ]]; then  # 24 hours
                    ((stale_count++))
                    health_score=$((health_score - 5))
                fi
            fi
        fi
    done
    
    health_report+=("Stale tasks: $stale_count")
    
    # Check for open escalations
    local open_escalations=0
    local esc_files=("$AGENT_STATE_DIR"/escalation_*.json)
    for esc_file in "${esc_files[@]}"; do
        if [[ -f "$esc_file" ]]; then
            local status
            status=$(jq -r '.status // "unknown"' "$esc_file")
            if [[ "$status" == "open" ]]; then
                ((open_escalations++))
                health_score=$((health_score - 10))
            fi
        fi
    done
    
    health_report+=("Open escalations: $open_escalations")
    health_report+=("Health score: $health_score/100")
    
    # Output health report
    printf '%s\n' "${health_report[@]}"
    
    # Record health metric
    agent_record_metric "$AGENT_NAME" "health_score" "$health_score"
    
    if [[ $health_score -lt 70 ]]; then
        agent_log "$AGENT_NAME" "WARN" "System health degraded: score $health_score"
    fi
}

cleanup_old_data() {
    local days="${1:-7}"
    
    agent_log "$AGENT_NAME" "INFO" "Cleaning up data older than $days days"
    
    local current_time
    current_time=$(date +%s)
    local cutoff_time=$((current_time - (days * 86400)))
    
    local cleaned_count=0
    
    # Clean old task files
    local task_files=("$AGENT_STATE_DIR"/task_*.json)
    for task_file in "${task_files[@]}"; do
        if [[ -f "$task_file" ]]; then
            local created
            created=$(jq -r '.created // ""' "$task_file")
            
            if [[ -n "$created" ]]; then
                local created_ts
                created_ts=$(date -d "$created" +%s 2>/dev/null || echo "0")
                
                if [[ $created_ts -lt $cutoff_time ]]; then
                    rm "$task_file"
                    ((cleaned_count++))
                fi
            fi
        fi
    done
    
    agent_log "$AGENT_NAME" "INFO" "Cleaned $cleaned_count old task files"
    
    echo "Cleaned $cleaned_count files older than $days days"
}

# --- Main Command Handler ---
usage() {
    echo "Anomaly Detection Agent v$VERSION"
    echo ""
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  scan <task_id>                        - Scan for anomalies"
    echo "  recover <task_id> <step_num> [action] - Trigger recovery (retry/fallback/escalate)"
    echo "  health                                - Monitor system health"
    echo "  cleanup [days]                        - Clean old data (default: 7 days)"
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
        scan)
            if [[ $# -lt 1 ]]; then
                echo "Error: scan requires <task_id>"
                exit 1
            fi
            scan_for_anomalies "$1"
            ;;
        recover)
            if [[ $# -lt 2 ]]; then
                echo "Error: recover requires <task_id> <step_num> [action]"
                exit 1
            fi
            trigger_recovery "$1" "$2" "${3:-retry}"
            ;;
        health)
            monitor_health
            ;;
        cleanup)
            cleanup_old_data "${1:-7}"
            ;;
        *)
            echo "Unknown command: $command"
            usage
            exit 1
            ;;
    esac
}

# Register this agent
agent_register "$AGENT_NAME" "$AGENT_TYPE" "anomaly_detection_agent.sh"

# Execute main if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
