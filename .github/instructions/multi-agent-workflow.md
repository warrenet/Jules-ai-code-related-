# Multi-Agent Workflow Assistant

This instruction guides Copilot to use the multi-agent workflow system for complex tasks.

## When to Use

Apply this workflow for tasks that involve:
- Complex problem-solving requiring multiple perspectives
- Code changes affecting multiple components
- Features requiring research, implementation, testing, and optimization
- Security-sensitive changes needing thorough review
- Performance-critical implementations

## Workflow Process

### 1. Research & Planning
- Break down the problem into manageable pieces
- Identify dependencies and prerequisites
- Define clear acceptance criteria
- Ask user for clarifications on vague requirements

### 2. Implementation
- Follow the research plan systematically
- Document reasoning at each step
- Handle edge cases explicitly
- Explain all assumptions made

### 3. Verification
- Test against acceptance criteria
- Check for errors and inefficiencies
- Suggest improvements and alternatives
- Flag issues for escalation if needed

### 4. Performance & Ethics Audit
- Measure key metrics (speed, cost, accuracy)
- Evaluate ethical implications (privacy, fairness, security)
- Compare results to targets
- Identify and document risks

### 5. Anomaly Detection
- Monitor for unexpected behavior
- Detect logic failures or process bottlenecks
- Trigger recovery steps when needed
- Log issues for continuous improvement

## Agent Collaboration

Agents work together through:
- **Shared state**: JSON files in `~/.local/share/termux-ai/workflows/`
- **Clear handoffs**: Each agent builds on previous work
- **Iterative refinement**: Loop until quality standards met
- **User feedback**: Incorporate clarifications throughout

## Best Practices

- **Define clear roles**: Each agent has specific responsibilities
- **Iterate relentlessly**: Don't accept first solution without verification
- **Log everything**: Document reasoning and decisions for transparency
- **Balance automation and interaction**: Prompt user when clarification needed
- **Audit ethically**: Check fairness, privacy, and security continuously

## Implementation Guide

1. Start with Research Agent to analyze problem
2. Implementation Agent develops solution following plan
3. Verification Agent validates work against criteria
4. Performance Auditor measures and evaluates
5. Anomaly Detection monitors throughout
6. Repeat refinement cycle until all standards met

Refer to `.github/agents/multi-agent-specialist.md` for detailed technical guidance.
