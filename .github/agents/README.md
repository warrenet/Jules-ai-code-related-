# GitHub Copilot Custom Agents

This directory contains specialized agent profiles that guide GitHub Copilot's behavior for different types of tasks.

## What Are Custom Agents?

Custom agents are specialized profiles that give GitHub Copilot deep expertise in specific domains. When you assign a task to Copilot that matches an agent's specialty, Copilot will follow that agent's detailed guidelines and best practices.

Think of them as expert teammates, each with specialized knowledge:
- **bash-expert.md** - Shell scripting expert
- **documentation-specialist.md** - Technical writing expert  
- **testing-expert.md** - Quality assurance expert
- **security-expert.md** - Security and privacy expert
- **multi-agent-specialist.md** - Complex problem-solving expert

## Available Agents

### 1. Bash Expert (`bash-expert.md`)

**Specialization**: Bash scripting, Termux compatibility, shell best practices

**Use for**:
- Creating or modifying shell scripts
- Implementing new CLI commands
- Optimizing Bash performance
- Ensuring Termux compatibility
- Working with pipes and streams

**Key expertise**:
- Secure input validation
- API key protection
- DRY_RUN mode compliance
- Error handling patterns
- Bash-native solutions

### 2. Documentation Specialist (`documentation-specialist.md`)

**Specialization**: Technical writing, user guides, API documentation

**Use for**:
- Writing or updating README files
- Creating user guides
- Documenting APIs and functions
- Writing troubleshooting guides
- Creating code examples

**Key expertise**:
- Clear, accessible writing
- Proper markdown formatting
- Working code examples
- Security documentation
- User-focused content

### 3. Testing Expert (`testing-expert.md`)

**Specialization**: Test development, TDD, quality assurance

**Use for**:
- Writing test cases
- Improving test coverage
- Implementing TDD workflows
- Testing security controls
- Setting up CI/CD tests

**Key expertise**:
- Comprehensive test patterns
- Edge case identification
- Security testing
- Mock environments
- Test isolation and cleanup

### 4. Security Expert (`security-expert.md`)

**Specialization**: Secure coding, input validation, privacy protection

**Use for**:
- Security reviews
- Input validation implementation
- API key protection
- Privacy compliance
- Vulnerability fixes

**Key expertise**:
- Zero-tolerance API key exposure
- Command injection prevention
- File system safety
- Secure temporary files
- Network security (HTTPS only)

### 5. Multi-Agent Specialist (`multi-agent-specialist.md`)

**Specialization**: Multi-agent workflows, complex problem-solving

**Use for**:
- Complex features requiring research and planning
- Multi-component changes
- Performance-critical implementations
- Security-sensitive changes
- Tasks needing systematic verification

**Key expertise**:
- Problem decomposition
- Agent coordination
- State management
- Iterative refinement
- Quality assurance workflows

## How to Use Custom Agents

### Automatic Assignment

GitHub Copilot will automatically reference the appropriate agent profile based on:
- File types being modified (`.sh` → bash-expert)
- Task type (tests → testing-expert)
- Keywords in the issue (security → security-expert)

### Explicit Reference

You can explicitly request an agent in your issue or PR:

```markdown
@copilot please review this using the security-expert profile
```

```markdown
@copilot use the bash-expert to implement this feature
```

### Task-Specific Guidance

For best results, provide context about what you need:

**For Bash changes**:
```markdown
Need to add a new CLI command for summarizing PDFs.
Should follow project security standards and work in Termux.
```

**For Documentation**:
```markdown
Update the README to explain the new PDF summarization feature.
Include installation steps and usage examples.
```

**For Testing**:
```markdown
Add comprehensive tests for the PDF summarizer.
Include security validation and edge case testing.
```

**For Security Review**:
```markdown
Review the PDF handler for security issues.
Ensure no path traversal and proper input validation.
```

**For Complex Tasks**:
```markdown
Implement end-to-end PDF processing workflow.
Use multi-agent approach for research, implementation, and verification.
```

## Agent Interaction Patterns

### Sequential Agent Use

For comprehensive changes, agents work together:

1. **Documentation Specialist** writes specs
2. **Bash Expert** implements code  
3. **Testing Expert** creates tests
4. **Security Expert** reviews security
5. **Multi-Agent Specialist** coordinates if complex

### Parallel Agent Use

For focused changes, use the right specialist:

- Security fix → **Security Expert** only
- New script → **Bash Expert** + **Testing Expert**
- Documentation → **Documentation Specialist** only
- Complex feature → **Multi-Agent Specialist** orchestrates

## Best Practices

### ✅ Do

- Reference the relevant agent profile in issues
- Provide clear context about the task
- Let the agent follow its expertise
- Review agent suggestions thoughtfully
- Use multi-agent for complex tasks

### ❌ Don't

- Assign security tasks to non-security agents
- Skip testing when adding code
- Ignore agent security recommendations
- Override agent best practices without good reason
- Use generic guidance when specialized agent exists

## Integration with Instructions

The `.github/instructions/` directory contains task-specific workflows:

- `multi-agent-workflow.md` - Complex problem-solving process
- `bug-fix-assistant.md` - Bug fixing and quality improvement
- `code-review-assistant.md` - Code review guidelines

These instruction files work together with agent profiles:

```
Issue Type          →  Instruction File        →  Agent Profiles Used
─────────────────────────────────────────────────────────────────────
Complex Feature     →  multi-agent-workflow    →  All agents coordinated
Bug Fix            →  bug-fix-assistant       →  Relevant domain expert
Code Review        →  code-review-assistant   →  All agents for review
New Script         →  (general guidelines)     →  bash-expert, testing-expert
Documentation      →  (general guidelines)     →  documentation-specialist
Security Issue     →  bug-fix-assistant       →  security-expert
```

## Customizing Agents

To customize or add new agents:

1. Create a new markdown file in this directory
2. Follow the format:
   ```markdown
   ---
   name: agent-name
   description: Brief description of expertise
   ---
   
   Agent content with detailed guidelines...
   ```
3. Update this README with the new agent
4. Reference the agent in issues or PRs

## Resources

- [Main Copilot Instructions](../copilot-instructions.md) - Overall project guidelines
- [Instructions Directory](../instructions/) - Task-specific workflows
- [GitHub Copilot Docs](https://docs.github.com/en/copilot) - Official documentation

---

**Remember**: These agents are here to help maintain code quality, security, and consistency. Use them to leverage specialized expertise for better outcomes.
