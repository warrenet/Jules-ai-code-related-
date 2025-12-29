#!/data/data/com.termux/files/usr/bin/bash
#
# agent_framework.sh
# Core framework for multi-agent AI workflow system
#
# Version: 1.0.0
#
# This framework provides the foundation for specialized AI agents that collaborate
# to solve complex problems through decomposition, implementation, verification,
# and continuous improvement.
#

# --- Strict Mode & Globals ---
set -Eeuo pipefail
IFS=$'\n\t'

# --- Version ---
FRAMEWORK_VERSION="1.0.0"

# --- Agent Framework Directories ---
AGENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_LOG_DIR="$HOME/.cache/termux-ai/agents"
AGENT_STATE_DIR="$HOME/.local/share/termux-ai/agents"

# Create directories if they don't exist
mkdir -p "$AGENT_LOG_DIR" "$AGENT_STATE_DIR"

# --- Logging Functions ---
agent_log() {
    local agent_name="$1"
    local level="$2"
    local message="$3"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_file="$AGENT_LOG_DIR/${agent_name}.log"
    
    local color
    case "$level" in
        INFO) color='\033[0;32m' ;;
        WARN) color='\033[0;33m' ;;
        ERROR) color='\033[0;31m' ;;
        DEBUG) color='\033[0;36m' ;;
        *) level="MSG"; color='\033[0m' ;;
    esac
    
    # Log to file
    echo "[$timestamp] [$level] $message" >> "$log_file"
    
    # Log to stderr with color
    printf >&2 "${color}[%s][%s] %s: %s\033[0m\n" "$timestamp" "$agent_name" "$level" "$message"
}

# --- Agent State Management ---
agent_save_state() {
    local agent_name="$1"
    local state_key="$2"
    local state_value="$3"
    local state_file="$AGENT_STATE_DIR/${agent_name}_state.json"
    
    # Create or update state file using jq
    if [[ -f "$state_file" ]]; then
        jq --arg key "$state_key" --arg value "$state_value" \
            '.[$key] = $value' "$state_file" > "${state_file}.tmp" && \
            mv "${state_file}.tmp" "$state_file"
    else
        jq -n --arg key "$state_key" --arg value "$state_value" \
            '{($key): $value}' > "$state_file"
    fi
    
    agent_log "$agent_name" "DEBUG" "Saved state: $state_key"
}

agent_load_state() {
    local agent_name="$1"
    local state_key="$2"
    local state_file="$AGENT_STATE_DIR/${agent_name}_state.json"
    
    if [[ -f "$state_file" ]]; then
        jq -r --arg key "$state_key" '.[$key] // empty' "$state_file"
    else
        echo ""
    fi
}

agent_clear_state() {
    local agent_name="$1"
    local state_file="$AGENT_STATE_DIR/${agent_name}_state.json"
    
    if [[ -f "$state_file" ]]; then
        rm "$state_file"
        agent_log "$agent_name" "INFO" "State cleared"
    fi
}

# --- Agent Communication ---
agent_send_message() {
    local from_agent="$1"
    local to_agent="$2"
    local message="$3"
    local message_file="$AGENT_STATE_DIR/message_${from_agent}_to_${to_agent}.json"
    
    jq -n \
        --arg from "$from_agent" \
        --arg to "$to_agent" \
        --arg msg "$message" \
        --arg timestamp "$(date -Iseconds)" \
        '{from: $from, to: $to, message: $msg, timestamp: $timestamp}' \
        > "$message_file"
    
    agent_log "$from_agent" "INFO" "Sent message to $to_agent"
}

agent_receive_message() {
    local agent_name="$1"
    local from_agent="${2:-*}"
    
    # Find messages addressed to this agent
    local message_pattern="$AGENT_STATE_DIR/message_${from_agent}_to_${agent_name}.json"
    
    for msg_file in $message_pattern; do
        if [[ -f "$msg_file" ]]; then
            cat "$msg_file"
            rm "$msg_file"  # Remove after reading
            return 0
        fi
    done
    
    return 1
}

# --- Agent Task Management ---
agent_create_task() {
    local agent_name="$1"
    local task_id="$2"
    local task_description="$3"
    local task_file="$AGENT_STATE_DIR/task_${agent_name}_${task_id}.json"
    
    jq -n \
        --arg id "$task_id" \
        --arg agent "$agent_name" \
        --arg desc "$task_description" \
        --arg status "pending" \
        --arg created "$(date -Iseconds)" \
        '{id: $id, agent: $agent, description: $desc, status: $status, created: $created}' \
        > "$task_file"
    
    agent_log "$agent_name" "INFO" "Created task: $task_id"
}

agent_update_task_status() {
    local agent_name="$1"
    local task_id="$2"
    local new_status="$3"
    local task_file="$AGENT_STATE_DIR/task_${agent_name}_${task_id}.json"
    
    if [[ -f "$task_file" ]]; then
        jq --arg status "$new_status" --arg updated "$(date -Iseconds)" \
            '.status = $status | .updated = $updated' \
            "$task_file" > "${task_file}.tmp" && \
            mv "${task_file}.tmp" "$task_file"
        
        agent_log "$agent_name" "INFO" "Updated task $task_id: $new_status"
    fi
}

agent_get_task_status() {
    local agent_name="$1"
    local task_id="$2"
    local task_file="$AGENT_STATE_DIR/task_${agent_name}_${task_id}.json"
    
    if [[ -f "$task_file" ]]; then
        jq -r '.status' "$task_file"
    else
        echo "not_found"
    fi
}

# --- Performance Metrics ---
agent_record_metric() {
    local agent_name="$1"
    local metric_name="$2"
    local metric_value="$3"
    local metrics_file="$AGENT_LOG_DIR/${agent_name}_metrics.json"
    
    local timestamp
    timestamp=$(date -Iseconds)
    
    # Append metric to file
    if [[ -f "$metrics_file" ]]; then
        jq --arg name "$metric_name" --arg value "$metric_value" --arg ts "$timestamp" \
            '. += [{name: $name, value: $value, timestamp: $ts}]' \
            "$metrics_file" > "${metrics_file}.tmp" && \
            mv "${metrics_file}.tmp" "$metrics_file"
    else
        jq -n --arg name "$metric_name" --arg value "$metric_value" --arg ts "$timestamp" \
            '[{name: $name, value: $value, timestamp: $ts}]' \
            > "$metrics_file"
    fi
}

agent_get_metrics() {
    local agent_name="$1"
    local metric_name="${2:-}"
    local metrics_file="$AGENT_LOG_DIR/${agent_name}_metrics.json"
    
    if [[ -f "$metrics_file" ]]; then
        if [[ -n "$metric_name" ]]; then
            jq --arg name "$metric_name" '[.[] | select(.name == $name)]' "$metrics_file"
        else
            cat "$metrics_file"
        fi
    else
        echo "[]"
    fi
}

# --- Agent Registration ---
declare -A REGISTERED_AGENTS

agent_register() {
    local agent_name="$1"
    local agent_type="$2"
    local agent_script="$3"
    
    REGISTERED_AGENTS["$agent_name"]="$agent_type:$agent_script"
    agent_log "framework" "INFO" "Registered agent: $agent_name ($agent_type)"
}

agent_get_info() {
    local agent_name="$1"
    echo "${REGISTERED_AGENTS[$agent_name]:-unknown:unknown}"
}

# --- Workflow Execution ---
agent_execute() {
    local agent_name="$1"
    shift
    local args=("$@")
    
    local agent_info
    agent_info=$(agent_get_info "$agent_name")
    local agent_script="${agent_info#*:}"
    
    if [[ "$agent_script" == "unknown" ]]; then
        agent_log "framework" "ERROR" "Agent not found: $agent_name"
        return 1
    fi
    
    agent_log "framework" "INFO" "Executing agent: $agent_name"
    
    # Execute the agent script
    bash "$AGENT_DIR/$agent_script" "${args[@]}"
}

# --- Utility Functions ---
agent_escalate() {
    local from_agent="$1"
    local issue="$2"
    local escalation_file
    escalation_file="$AGENT_STATE_DIR/escalation_$(date +%s).json"
    
    jq -n \
        --arg from "$from_agent" \
        --arg issue "$issue" \
        --arg timestamp "$(date -Iseconds)" \
        '{from: $from, issue: $issue, timestamp: $timestamp, status: "open"}' \
        > "$escalation_file"
    
    agent_log "$from_agent" "WARN" "Escalated issue: $issue"
}

agent_list_escalations() {
    local escalations=("$AGENT_STATE_DIR"/escalation_*.json)
    
    if [[ -f "${escalations[0]}" ]]; then
        for esc in "${escalations[@]}"; do
            cat "$esc"
            echo ""
        done
    else
        echo "No escalations found"
    fi
}

# --- Export Functions ---
export -f agent_log
export -f agent_save_state
export -f agent_load_state
export -f agent_clear_state
export -f agent_send_message
export -f agent_receive_message
export -f agent_create_task
export -f agent_update_task_status
export -f agent_get_task_status
export -f agent_record_metric
export -f agent_get_metrics
export -f agent_register
export -f agent_get_info
export -f agent_execute
export -f agent_escalate
export -f agent_list_escalations

# Export directory variables
export AGENT_DIR
export AGENT_LOG_DIR
export AGENT_STATE_DIR
export FRAMEWORK_VERSION

agent_log "framework" "INFO" "Agent Framework v$FRAMEWORK_VERSION initialized"
