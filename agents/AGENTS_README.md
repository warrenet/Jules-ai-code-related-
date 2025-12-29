# Multi-Agent AI Workflow System

## Overview

The Multi-Agent AI Workflow System is an advanced framework that coordinates specialized AI agents to solve complex problems through decomposition, implementation, verification, and continuous improvement.

## Architecture

### Core Components

1. **Agent Framework** (`agent_framework.sh`)
   - Provides foundational services for all agents
   - Handles logging, state management, inter-agent communication
   - Manages task tracking and performance metrics

2. **Research Agent** (`research_agent.sh`)
   - Breaks down complex problems into manageable pieces
   - Identifies dependencies and prerequisites
   - Generates clarification questions
   - Creates execution plans

3. **Implementation Agent** (`implementation_agent.sh`)
   - Develops solutions based on execution plans
   - Documents reasoning and assumptions
   - Implements with clear edge case handling
   - Tracks implementation metrics

4. **Verification Agent** (`verification_agent.sh`)
   - Assesses implementations for errors and inefficiencies
   - Performs security checks
   - Flags issues for correction
   - Suggests alternative approaches

5. **Performance Auditor** (`performance_auditor.sh`)
   - Analyzes performance metrics (speed, cost, accuracy)
   - Checks ethical compliance
   - Estimates costs
   - Generates comprehensive reports

6. **Anomaly Detection Agent** (`anomaly_detection_agent.sh`)
   - Scans for unexpected outputs and failures
   - Triggers automated recovery (retry, fallback, escalate)
   - Monitors system health
   - Cleans up old data

7. **Workflow Orchestrator** (`workflow_orchestrator.sh`)
   - Coordinates all agents
   - Executes full workflows
   - Provides interactive mode
   - Manages workflow lifecycle

## Installation

### Prerequisites

- Bash 4.0 or higher
- `jq` for JSON processing
- `bc` for calculations
- Existing Termux AI Toolkit installation

### Setup

```bash
# Clone or navigate to the repository
cd /path/to/Jules-ai-code-related-

# The agents directory is already included
cd agents

# Make all scripts executable (already done)
chmod +x *.sh

# Verify installation
bash workflow_orchestrator.sh --help
```

## Usage

### Quick Start

#### 1. Execute a Full Automated Workflow

```bash
bash agents/workflow_orchestrator.sh run "Create a Python web scraper for news articles" task_001
```

This will:
- Decompose the problem
- Create an execution plan
- Implement each step
- Verify the implementation
- Audit performance and ethics
- Generate a comprehensive report

#### 2. Interactive Workflow

```bash
bash agents/workflow_orchestrator.sh interactive "Optimize database queries for better performance"
```

This allows you to review and approve each phase before proceeding.

### Individual Agent Usage

#### Research Agent

```bash
# Decompose a problem
bash agents/research_agent.sh decompose "Build a REST API" task_002

# Identify dependencies
bash agents/research_agent.sh dependencies task_002

# Get clarifications
bash agents/research_agent.sh clarify task_002

# Create execution plan
bash agents/research_agent.sh plan task_002
```

#### Implementation Agent

```bash
# Implement a single step
bash agents/implementation_agent.sh step task_002 0 "Set up project structure"

# Implement full plan
bash agents/implementation_agent.sh full task_002

# Document implementation
bash agents/implementation_agent.sh document task_002 0

# View metrics
bash agents/implementation_agent.sh metrics
```

#### Verification Agent

```bash
# Verify a single step
bash agents/verification_agent.sh verify task_002 0

# Verify full implementation
bash agents/verification_agent.sh verify-full task_002

# Security check
bash agents/verification_agent.sh security task_002 0

# Generate report
bash agents/verification_agent.sh report task_002
```

#### Performance Auditor

```bash
# Audit performance
bash agents/performance_auditor.sh audit task_002

# Analyze efficiency
bash agents/performance_auditor.sh efficiency task_002 120

# Check ethics
bash agents/performance_auditor.sh ethics task_002

# Estimate cost
bash agents/performance_auditor.sh cost task_002 0.001

# Generate comprehensive report
bash agents/performance_auditor.sh report task_002
```

#### Anomaly Detection Agent

```bash
# Scan for anomalies
bash agents/anomaly_detection_agent.sh scan task_002

# Trigger recovery
bash agents/anomaly_detection_agent.sh recover task_002 0 retry

# Monitor health
bash agents/anomaly_detection_agent.sh health

# Cleanup old data
bash agents/anomaly_detection_agent.sh cleanup 7
```

### Workflow Management

```bash
# List all workflows
bash agents/workflow_orchestrator.sh list

# Get workflow status
bash agents/workflow_orchestrator.sh status task_001

# Cleanup workflow data
bash agents/workflow_orchestrator.sh cleanup task_001

# Check system health
bash agents/workflow_orchestrator.sh health
```

## Data Storage

All agent data is stored in isolated directories:

- **Logs**: `~/.cache/termux-ai/agents/`
  - `{agent_name}.log` - Agent execution logs
  - `{agent_name}_metrics.json` - Performance metrics

- **State**: `~/.local/share/termux-ai/agents/`
  - `{agent_name}_state.json` - Agent state data
  - `task_*.json` - Task information
  - `execution_plan_*.json` - Execution plans
  - `implementation_results_*.json` - Implementation results
  - `verification_summary_*.json` - Verification summaries
  - `workflow_summary_*.json` - Workflow summaries
  - `message_*.json` - Inter-agent messages
  - `escalation_*.json` - Escalated issues

## Agent Communication

Agents communicate through a message-passing system:

```bash
# In agent code:
agent_send_message "research" "implementation" "Plan ready for execution"

# Receiving messages:
agent_receive_message "implementation" "research"
```

## Workflow Phases

### Phase 1: Research & Planning
1. Problem decomposition
2. Dependency identification
3. Clarification generation
4. Execution plan creation

### Phase 2: Implementation
1. Step-by-step solution development
2. Documentation of approach and assumptions
3. Edge case handling
4. Testing approach definition

### Phase 3: Verification
1. Logic error detection
2. Security vulnerability scanning
3. Performance issue identification
4. Quality assessment

### Phase 4: Performance Audit
1. Metrics analysis
2. Cost estimation
3. Ethical compliance check
4. Comprehensive reporting

### Phase 5: Anomaly Detection & Recovery
1. Failure detection
2. Automated recovery
3. Health monitoring
4. Issue logging

## Advanced Features

### Escalation System

When agents encounter critical issues:

```bash
agent_escalate "agent_name" "Description of issue"
```

View all escalations:

```bash
agent_list_escalations
```

### Metrics Tracking

Record custom metrics:

```bash
agent_record_metric "agent_name" "metric_name" "value"
```

Retrieve metrics:

```bash
agent_get_metrics "agent_name" "metric_name"
```

### Task Management

Create and track tasks:

```bash
agent_create_task "agent_name" "task_id" "description"
agent_update_task_status "agent_name" "task_id" "completed"
agent_get_task_status "agent_name" "task_id"
```

### State Management

Save and load agent state:

```bash
agent_save_state "agent_name" "key" "value"
value=$(agent_load_state "agent_name" "key")
agent_clear_state "agent_name"
```

## Integration with Existing Toolkit

The agent system integrates seamlessly with the existing Termux AI Toolkit:

- Uses `ai_cli.sh` for AI interactions
- Stores data in toolkit directories
- Follows the same safety principles
- Respects `DRY_RUN` mode

## Error Handling and Recovery

### Automatic Recovery Strategies

1. **Retry**: Re-execute failed steps
2. **Fallback**: Use alternative approaches
3. **Escalate**: Flag for human intervention

### Recovery Triggers

```bash
# Manual recovery
bash agents/anomaly_detection_agent.sh recover task_id step_number retry

# Recovery actions: retry, fallback, escalate
```

## Performance Optimization

### Best Practices

1. Use specific task IDs for tracking
2. Clean up old data regularly
3. Monitor system health
4. Review escalations promptly
5. Analyze metrics for improvement

### Monitoring

```bash
# Check system health
bash agents/anomaly_detection_agent.sh health

# View metrics
bash agents/implementation_agent.sh metrics

# Review performance
bash agents/performance_auditor.sh report task_id
```

## Troubleshooting

### Common Issues

**Issue**: Agent script not found
```bash
# Ensure you're in the correct directory
cd /path/to/Jules-ai-code-related-/agents
# Make scripts executable
chmod +x *.sh
```

**Issue**: jq command not found
```bash
# Install jq
pkg install jq  # Termux
apt-get install jq  # Debian/Ubuntu
```

**Issue**: State directory not found
```bash
# Directories are created automatically
# Check permissions
ls -ld ~/.local/share/termux-ai/agents/
```

**Issue**: Agent communication failures
```bash
# Check for stuck messages
ls ~/.local/share/termux-ai/agents/message_*.json
# Clean up if needed
rm ~/.local/share/termux-ai/agents/message_*.json
```

### Debugging

Enable detailed logging:

```bash
# View agent logs
tail -f ~/.cache/termux-ai/agents/research.log
tail -f ~/.cache/termux-ai/agents/implementation.log
tail -f ~/.cache/termux-ai/agents/verification.log
```

Check agent state:

```bash
# View state files
cat ~/.local/share/termux-ai/agents/research_state.json | jq '.'
```

## Security Considerations

### Safety Features

1. **Isolated Workspace**: Agents only write to dedicated directories
2. **API Key Protection**: Keys are never logged or exposed
3. **Input Validation**: All inputs are validated
4. **Error Containment**: Failures don't cascade
5. **Audit Trail**: All actions are logged

### Security Checks

The Verification Agent performs automatic security checks:
- Input validation issues
- Injection vulnerabilities
- Authentication/authorization flaws
- Data exposure risks
- Unsafe operations

## Examples

### Example 1: Simple Task

```bash
bash agents/workflow_orchestrator.sh run "Write a bash function to parse CSV files" csv_parser_001
```

### Example 2: Complex Project

```bash
# Interactive workflow for detailed control
bash agents/workflow_orchestrator.sh interactive "Build a microservices architecture with authentication"
```

### Example 3: Performance Analysis

```bash
# Run workflow
bash agents/workflow_orchestrator.sh run "Optimize image processing pipeline" optimize_001

# Analyze results
bash agents/performance_auditor.sh report optimize_001

# Check for issues
bash agents/anomaly_detection_agent.sh scan optimize_001
```

## API Reference

See individual agent scripts for complete function documentation:
- `agent_framework.sh` - Core functions
- `research_agent.sh` - Planning functions
- `implementation_agent.sh` - Building functions
- `verification_agent.sh` - QA functions
- `performance_auditor.sh` - Audit functions
- `anomaly_detection_agent.sh` - Monitoring functions
- `workflow_orchestrator.sh` - Coordination functions

## Contributing

When extending the agent system:

1. Follow the agent template structure
2. Use the agent framework functions
3. Register new agents properly
4. Add comprehensive logging
5. Document all functions
6. Include usage examples

## License

This agent system is part of the Termux AI Toolkit and follows the same MIT License.

## Support

For issues, questions, or contributions:
- Check the agent logs
- Review escalations
- Monitor system health
- Open an issue on GitHub

---

**Version**: 1.0.0  
**Last Updated**: November 2024  
**Maintainer**: Termux AI Toolkit Team
