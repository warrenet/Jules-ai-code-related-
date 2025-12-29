# Bug Fix and Code Quality Assistant

This instruction guides Copilot when fixing bugs and improving code quality.

## Primary Objectives

1. **Fix bugs** efficiently with minimal code changes
2. **Maintain code quality** according to project standards
3. **Ensure security** in all fixes
4. **Add tests** to prevent regression
5. **Document** the fix clearly

## Bug Fixing Process

### 1. Understand the Problem
- Read the bug report or issue description carefully
- Reproduce the bug if possible
- Identify the root cause, not just symptoms
- Check for similar issues in the codebase

### 2. Analyze Impact
- Determine which files/functions are affected
- Check for dependencies and side effects
- Review existing tests that might be affected
- Consider backward compatibility

### 3. Plan the Fix
- Choose the minimal change approach
- Consider edge cases and error handling
- Plan for test coverage
- Think about documentation needs

### 4. Implement the Fix
- Make surgical, focused changes
- Follow project coding standards (see `.github/copilot-instructions.md`)
- Add input validation if security-related
- Respect DRY_RUN mode for file operations
- Never expose API keys or secrets

### 5. Test Thoroughly
- Add specific tests for the bug
- Verify existing tests still pass
- Test edge cases
- Run the full test suite: `bash tests.sh`

### 6. Document Changes
- Update code comments if logic changed
- Update documentation if behavior changed
- Write clear commit messages
- Add troubleshooting info if needed

## Code Quality Standards

### For Bash Scripts
- Use strict mode: `set -Eeuo pipefail`
- Quote all variables: `"$var"` not `$var`
- Validate all inputs before use
- Implement proper error handling
- Follow naming conventions:
  - UPPERCASE for constants
  - lowercase for local variables
  - snake_case for functions

### For JavaScript
- Use modern ES6+ syntax
- Add comments for complex logic
- Validate user inputs
- Handle errors gracefully
- Keep functions focused and single-purpose

### Security Checklist
- [ ] No API keys or secrets in code
- [ ] All user inputs validated and sanitized
- [ ] File operations respect DRY_RUN mode
- [ ] No command injection vulnerabilities
- [ ] Error messages don't expose sensitive info
- [ ] HTTPS only for network calls

### Testing Checklist
- [ ] Bug has a specific test case
- [ ] Test covers the fix
- [ ] Test would fail without the fix
- [ ] Existing tests still pass
- [ ] Edge cases are tested
- [ ] Security validations are tested

## Common Bug Categories

### Input Validation Bugs
```bash
# Before (vulnerable)
file="$1"
cat "$file"

# After (safe)
file="$1"
[[ -z "$file" ]] && die "File path required"
[[ "$file" =~ \.\. ]] && die "Path traversal not allowed"
[[ ! -r "$file" ]] && die "File not found or not readable"
cat "$file"
```

### Error Handling Bugs
```bash
# Before (silent failure)
result=$(some_command)
process "$result"

# After (proper error handling)
if ! result=$(some_command 2>&1); then
    die "Command failed: $result"
fi
process "$result"
```

### API Key Exposure Bugs
```bash
# Before (exposes key)
echo "Using API key: $OPENAI_API_KEY"

# After (masked)
masked_key="${OPENAI_API_KEY:0:8}****"
echo "Using API key: $masked_key"
```

### File Permission Bugs
```bash
# Before (assumes writable)
echo "data" > "$output_file"

# After (checks DRY_RUN)
if [[ "${DRY_RUN:-1}" -eq 0 ]]; then
    echo "data" > "$output_file"
else
    echo "DRY_RUN: Would write to $output_file"
fi
```

## What NOT to Do

- ❌ Don't make unrelated changes while fixing bugs
- ❌ Don't skip testing your fix
- ❌ Don't break existing functionality
- ❌ Don't introduce security vulnerabilities
- ❌ Don't remove tests to make builds pass
- ❌ Don't hide errors with silent catches
- ❌ Don't commit without running tests

## Tools and Resources

### Run Tests
```bash
# Full test suite
bash tests.sh

# Specific test file
bash tests_prompt_eval.sh

# With verbose output
DEBUG=1 bash tests.sh
```

### Check Code Style
```bash
# ShellCheck for Bash scripts
shellcheck script.sh

# Prettier for web files (if configured)
prettier --check index.html script.js
```

### Review Security
Refer to `.github/agents/security-expert.md` for detailed security guidance.

### Follow Patterns
Look at existing scripts for consistent patterns and style.

## Reporting the Fix

When completing the fix:
1. Summarize what was broken
2. Explain the root cause
3. Describe the fix
4. List tests added
5. Note any side effects or breaking changes

Refer to `.github/agents/bash-expert.md` and `.github/agents/security-expert.md` for specialized guidance.
