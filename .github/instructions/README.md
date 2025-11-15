# GitHub Copilot Task Instructions

This directory contains task-specific instruction files that guide GitHub Copilot through different types of workflows.

## What Are Task Instructions?

Task instructions are workflow guides that tell GitHub Copilot how to approach specific types of tasks. They complement the custom agent profiles in `.github/agents/` by providing procedural guidance.

## Available Instructions

### 1. Multi-Agent Workflow (`multi-agent-workflow.md`)

**Purpose**: Guide Copilot through complex, multi-phase problem-solving

**Use for**:
- Features requiring research and planning
- Changes affecting multiple components
- Security-sensitive implementations
- Performance-critical code
- Tasks needing systematic verification

**Process**:
1. Research & Planning → Decompose problem, define criteria
2. Implementation → Follow plan, document reasoning
3. Verification → Test against criteria, find issues
4. Performance Audit → Measure metrics, check ethics
5. Anomaly Detection → Monitor and auto-correct

**Example assignment**:
```markdown
@copilot use multi-agent-workflow to implement real-time log analyzer
```

### 2. Bug Fix Assistant (`bug-fix-assistant.md`)

**Purpose**: Guide Copilot through efficient, thorough bug fixing

**Use for**:
- Fixing reported bugs
- Addressing test failures
- Resolving security vulnerabilities
- Improving code quality issues
- Handling edge case failures

**Process**:
1. Understand the Problem → Reproduce, find root cause
2. Analyze Impact → Check dependencies, side effects
3. Plan the Fix → Minimal change, consider edge cases
4. Implement → Surgical fixes, follow standards
5. Test → Add tests, verify no regression
6. Document → Update docs, clear commit messages

**Example assignment**:
```markdown
@copilot use bug-fix-assistant to fix API key exposure in logs
```

### 3. Code Review Assistant (`code-review-assistant.md`)

**Purpose**: Guide Copilot through comprehensive code review

**Use for**:
- Reviewing pull requests
- Pre-merge quality checks
- Security audits
- Documentation reviews
- Style consistency checks

**Review areas**:
- Code quality and style
- Functionality and logic
- Security vulnerabilities
- Test coverage
- Documentation completeness

**Example usage**:
```markdown
@copilot use code-review-assistant to review PR #123
```

## How Instructions Work with Agents

Instructions define the **workflow** (what to do), while agents provide **expertise** (how to do it well).

### Example: Fixing a Security Bug

1. **Instruction**: `bug-fix-assistant.md` - Provides the bug-fixing workflow
2. **Agent**: `security-expert.md` - Provides security-specific expertise
3. **Result**: Systematic bug fix following security best practices

### Example: Complex Feature

1. **Instruction**: `multi-agent-workflow.md` - Provides the multi-phase workflow
2. **Agents**: Multiple agents coordinate (bash-expert, testing-expert, security-expert)
3. **Result**: Well-researched, tested, secure implementation

## Using Task Instructions

### In Issues

Reference the instruction in your issue description:

```markdown
## Task Description
Implement PDF text extraction feature

## Workflow
Use multi-agent-workflow for systematic implementation

## Requirements
- Security-first approach
- Comprehensive testing
- Complete documentation
```

### In Pull Request Reviews

```markdown
@copilot please use code-review-assistant to review this PR
Focus on security and test coverage
```

### In Comments

```markdown
@copilot use bug-fix-assistant to investigate why tests are failing
```

## Choosing the Right Instruction

### Use `multi-agent-workflow.md` when:
- ✅ Task is complex with multiple moving parts
- ✅ You need research before implementation
- ✅ Security and performance are critical
- ✅ Multiple verification steps needed
- ✅ You want systematic quality assurance

### Use `bug-fix-assistant.md` when:
- ✅ There's a specific bug to fix
- ✅ Tests are failing
- ✅ Code quality needs improvement
- ✅ Security vulnerability needs patching
- ✅ You need focused, surgical changes

### Use `code-review-assistant.md` when:
- ✅ Reviewing someone's pull request
- ✅ Doing pre-merge quality check
- ✅ Auditing for security issues
- ✅ Checking documentation completeness
- ✅ Verifying test coverage

## Creating Custom Instructions

To add new task instructions:

1. Create a new `.md` file in this directory
2. Define the purpose and use cases
3. Outline the workflow steps
4. Include examples and checklists
5. Reference relevant agent profiles
6. Update this README

### Template Structure

```markdown
# [Instruction Name]

Brief description of what this instruction guides.

## When to Use

List of scenarios where this instruction applies.

## Process

Step-by-step workflow:
1. Step one with details
2. Step two with details
...

## Best Practices

Key points to remember when following this instruction.

## Integration with Agents

Which agent profiles work best with this instruction.

## Example

Concrete example of the instruction in action.
```

## Best Practices

### ✅ Do

- Choose the instruction that best fits your task
- Provide clear context about the work needed
- Reference specific agent profiles if relevant
- Follow the instruction's workflow systematically
- Iterate based on feedback

### ❌ Don't

- Mix instructions for a single task (choose one)
- Skip steps in the workflow
- Ignore security or testing guidance
- Override best practices without reason
- Use overly generic instructions when specific ones exist

## Relationship with Other Documentation

```
.github/
├── copilot-instructions.md    ← Overall project guidelines and standards
├── agents/                     ← Domain-specific expertise (how)
│   ├── bash-expert.md
│   ├── security-expert.md
│   └── ...
└── instructions/               ← Task-specific workflows (what)
    ├── multi-agent-workflow.md
    ├── bug-fix-assistant.md
    └── code-review-assistant.md
```

**Workflow**:
1. Issue created → Choose appropriate **instruction**
2. Instruction guides overall **workflow**
3. Each step uses relevant **agent expertise**
4. All work follows **copilot-instructions.md** standards

## Examples

### Example 1: New Feature

**Task**: Add support for analyzing images with AI

**Workflow**:
```markdown
@copilot use multi-agent-workflow

Requirements:
- Support multiple image formats
- Integrate with OpenAI Vision API
- Secure API key handling
- Comprehensive error handling
- Full test coverage
```

**Agents involved**: bash-expert, security-expert, testing-expert

### Example 2: Bug Fix

**Task**: Fix issue where temp files aren't cleaned up

**Workflow**:
```markdown
@copilot use bug-fix-assistant

Bug: Temporary files persist after script exits
Expected: Files cleaned up via trap
```

**Agents involved**: bash-expert, testing-expert

### Example 3: Code Review

**Task**: Review security improvements PR

**Workflow**:
```markdown
@copilot use code-review-assistant

Focus areas:
- Input validation
- API key handling
- File operation safety
- Test coverage for security
```

**Agents involved**: security-expert, testing-expert

## Resources

- [Custom Agents](../agents/) - Domain expertise profiles
- [Main Instructions](../copilot-instructions.md) - Project-wide guidelines
- [GitHub Copilot Docs](https://docs.github.com/en/copilot/tutorials/coding-agent/get-the-best-results) - Best practices

---

**Remember**: Instructions provide the roadmap, agents provide the expertise, and together they help you build high-quality, secure code efficiently.
