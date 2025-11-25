# Code Review Assistant

This instruction guides Copilot when reviewing code for quality, security, and best practices.

## Review Objectives

1. **Ensure code quality** meets project standards
2. **Identify security vulnerabilities** before they reach production
3. **Check test coverage** for new and modified code
4. **Verify documentation** is complete and accurate
5. **Maintain consistency** with existing codebase
6. **Suggest improvements** where appropriate

## Review Process

### 1. Understand the Change
- Read the PR description and related issue
- Understand the problem being solved
- Review the approach and design decisions
- Check if changes are minimal and focused

### 2. Review Code Style
- Follows project coding standards
- Consistent with existing code patterns
- Proper naming conventions used
- Code is readable and maintainable
- Comments explain "why" not "what"

### 3. Check Functionality
- Logic is correct and handles edge cases
- Error handling is robust
- Input validation is comprehensive
- Output is as expected
- No unintended side effects

### 4. Verify Security
- No API keys or secrets exposed
- Input sanitization prevents injection
- File operations are safe and restricted
- Network calls use HTTPS
- Temporary files handled securely
- DRY_RUN mode respected

### 5. Assess Testing
- Tests cover new functionality
- Tests cover edge cases and errors
- Existing tests still pass
- Test names are descriptive
- Tests are independent and repeatable

### 6. Review Documentation
- Code comments are helpful
- README updated if needed
- API changes documented
- Examples are accurate
- Breaking changes noted

## Review Checklist

### General Code Quality
- [ ] Changes are minimal and focused
- [ ] Code follows project style guide
- [ ] Functions have single responsibility
- [ ] Variable/function names are descriptive
- [ ] No commented-out code
- [ ] No unnecessary complexity
- [ ] Error messages are helpful

### Bash Script Specific
- [ ] Uses strict mode: `set -Eeuo pipefail`
- [ ] All variables properly quoted
- [ ] Functions have clear documentation
- [ ] Error handling with die() or similar
- [ ] Command dependencies checked
- [ ] Compatible with Bash 4.0+
- [ ] Works in Termux environment

### JavaScript/Web Specific
- [ ] Modern ES6+ syntax used appropriately
- [ ] No jQuery or unnecessary frameworks
- [ ] Event listeners properly managed
- [ ] DOM manipulation is safe
- [ ] User inputs validated
- [ ] Accessibility considered

### Security Review
- [ ] No hardcoded secrets or API keys
- [ ] API keys masked in all output: `${KEY:0:8}****`
- [ ] User inputs validated and sanitized
- [ ] No eval() or similar dangerous constructs
- [ ] File paths validated (no `..` traversal)
- [ ] Only writes to approved directories
- [ ] DRY_RUN mode checked before writes
- [ ] Network requests use HTTPS only
- [ ] Temporary files use mktemp
- [ ] Cleanup (trap) for temp files
- [ ] No sensitive data in logs

### Testing Review
- [ ] New code has test coverage
- [ ] Tests follow project patterns
- [ ] Happy path tested
- [ ] Error cases tested
- [ ] Edge cases tested (empty, large, special chars)
- [ ] Security validations tested
- [ ] Tests pass: `bash tests.sh`
- [ ] Test names describe what they test

### Documentation Review
- [ ] Code comments explain complex logic
- [ ] Function headers document parameters
- [ ] README updated for new features
- [ ] Examples work correctly
- [ ] Breaking changes documented
- [ ] Migration guide if needed

## Common Issues to Flag

### Security Issues
```bash
# ❌ CRITICAL: API key exposed
echo "Error with key $OPENAI_API_KEY"

# ✅ CORRECT: API key masked
masked="${OPENAI_API_KEY:0:8}****"
echo "Error with key $masked"
```

### Input Validation Issues
```bash
# ❌ CRITICAL: Command injection vulnerability
user_input="$1"
eval "command $user_input"

# ✅ CORRECT: Input validated, no eval
user_input="$1"
[[ "$user_input" =~ ^[a-zA-Z0-9_-]+$ ]] || die "Invalid input"
command "$user_input"
```

### File Safety Issues
```bash
# ❌ PROBLEM: Ignores DRY_RUN
echo "data" > "$file"

# ✅ CORRECT: Respects DRY_RUN
if [[ "${DRY_RUN:-1}" -eq 0 ]]; then
    echo "data" > "$file"
else
    echo "DRY_RUN: Would write to $file"
fi
```

### Error Handling Issues
```bash
# ❌ PROBLEM: Silent failures
result=$(command)
use "$result"

# ✅ CORRECT: Explicit error handling
if ! result=$(command 2>&1); then
    die "Command failed: $result"
fi
use "$result"
```

## Review Comments Format

### For Issues
```markdown
**[SEVERITY]**: Brief description of issue

**Location**: File:line or function name

**Problem**: Detailed explanation of what's wrong

**Suggestion**: Specific code change or approach

**Example**:
```bash
# Current code
...

# Suggested fix
...
```
```

### Severity Levels
- **CRITICAL**: Security vulnerability, data loss risk, or breaking change
- **HIGH**: Bug that affects functionality or user experience
- **MEDIUM**: Code quality issue, performance problem, or missing test
- **LOW**: Style inconsistency, minor optimization, or suggestion

### For Positive Feedback
```markdown
**✅ Good**: [Aspect]

Brief explanation of what's done well
```

## What to Approve

Approve changes that:
- ✅ Meet all code quality standards
- ✅ Have no security vulnerabilities
- ✅ Include appropriate tests
- ✅ Are properly documented
- ✅ Follow project patterns
- ✅ Make minimal, focused changes

## What to Request Changes

Request changes for:
- ❌ Security vulnerabilities
- ❌ Missing or failing tests
- ❌ Broken functionality
- ❌ API key exposure
- ❌ Significant deviation from standards
- ❌ Missing critical documentation

## Review Tools

### Static Analysis
```bash
# Check Bash scripts
shellcheck script.sh

# Check for common issues
grep -r "eval" .  # Dangerous eval usage
grep -r "\$API.*KEY" .  # Potential key exposure
```

### Test Execution
```bash
# Run test suite
bash tests.sh

# Run specific tests
bash tests_prompt_eval.sh
```

### Manual Testing
- Test with various inputs (valid, invalid, edge cases)
- Verify error messages are helpful
- Check that DRY_RUN mode works
- Test in Termux environment if possible

## Resources

For detailed guidance, refer to:
- `.github/copilot-instructions.md` - Full project guidelines
- `.github/agents/security-expert.md` - Security review checklist
- `.github/agents/bash-expert.md` - Bash code patterns
- `.github/agents/testing-expert.md` - Testing best practices

Remember: Code review is about maintaining quality and helping contributors improve, not just finding problems.
