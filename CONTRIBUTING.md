# Contributing to Termux AI Toolkit

Thank you for your interest in contributing to the Termux AI Toolkit! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [How to Contribute](#how-to-contribute)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Pull Request Process](#pull-request-process)
- [Reporting Bugs](#reporting-bugs)
- [Suggesting Features](#suggesting-features)

## Code of Conduct

This project and everyone participating in it is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior to the project maintainers.

## Getting Started

1. Fork the repository on GitHub
2. Clone your fork locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/Jules-ai-code-related-.git
   cd Jules-ai-code-related-
   ```
3. Add the upstream repository:
   ```bash
   git remote add upstream https://github.com/warrenet/Jules-ai-code-related-.git
   ```
4. Create a branch for your changes:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Setup

### Prerequisites

For local development and testing:

- A Linux environment (Termux, WSL, or native Linux)
- Bash 4.0 or higher
- `curl` and `jq` installed
- (Optional) An API key for testing (OpenAI or Gemini)

### Installation

```bash
# Make all scripts executable
chmod +x *.sh

# Install dependencies
# On Termux:
pkg install curl jq

# On Debian/Ubuntu:
sudo apt-get install curl jq

# Set up your test environment
cp 01_env_template.sh ~/.config/termux-ai/env
# Edit the file to add a test API key (if needed)
nano ~/.config/termux-ai/env

# (Optional) Install pre-commit hook for automated quality checks
ln -s ../../scripts/pre-commit-hook.sh .git/hooks/pre-commit
echo "Pre-commit hook installed!"
```

### Pre-commit Hook (Recommended)

The repository includes a pre-commit hook that automatically checks your changes before committing:

- Runs ShellCheck on modified shell scripts
- Detects hardcoded API keys
- Verifies shell scripts are executable
- Checks JavaScript/HTML formatting

To install the pre-commit hook:

```bash
ln -s ../../scripts/pre-commit-hook.sh .git/hooks/pre-commit
```

You can also run the checks manually:

```bash
bash scripts/pre-commit-hook.sh
```

## How to Contribute

### Types of Contributions

We welcome several types of contributions:

1. **Bug Fixes**: Fix issues reported in the issue tracker
2. **New Features**: Add new functionality
3. **Documentation**: Improve README, guides, or code comments
4. **Tests**: Add or improve test coverage
5. **Performance**: Optimize existing code
6. **Security**: Identify and fix security issues

### Before You Start

1. Check the [issue tracker](https://github.com/warrenet/Jules-ai-code-related-/issues) to see if someone else is already working on it
2. For major changes, open an issue first to discuss your approach
3. For minor fixes (typos, small bugs), feel free to submit a PR directly

## Coding Standards

### Bash Script Guidelines

#### General Principles

- **Safety First**: All scripts should be non-destructive by default
- **Clear Error Messages**: Provide helpful, actionable error messages
- **User Control**: Never make system changes without explicit user consent
- **Fail Fast**: Use `set -Eeuo pipefail` for robust error handling

#### Style Guidelines

1. **Shebang**: Use `#!/data/data/com.termux/files/usr/bin/bash` for Termux compatibility
   ```bash
   #!/data/data/com.termux/files/usr/bin/bash
   ```

2. **Strict Mode**: Always start scripts with:
   ```bash
   set -Eeuo pipefail
   IFS=$'\n\t'
   ```

3. **Comments**: Use clear, concise comments
   ```bash
   # --- Section Header ---
   # Brief description of what this section does
   function_name() {
       # Explain complex logic
       local var="value"
   }
   ```

4. **Variables**:
   - Use UPPERCASE for constants and environment variables
   - Use lowercase for local variables
   - Use descriptive names
   ```bash
   API_ENDPOINT="https://api.openai.com/v1/chat/completions"
   local user_input=""
   ```

5. **Functions**:
   - Use snake_case for function names
   - Add usage comments
   ```bash
   # Usage: log "LEVEL" "message"
   log() {
       local level="$1" msg="$2"
       echo "[$level] $msg" >&2
   }
   ```

6. **Error Handling**:
   ```bash
   die() {
       log "ERROR" "$1"
       exit 1
   }

   require_cmd() {
       command -v "$1" >/dev/null || die "Required command '$1' not found"
   }
   ```

### Security Requirements

1. **API Key Protection**:
   - Never log API keys
   - Never include keys in error messages
   - Always mask keys in debug output

2. **Input Validation**:
   - Validate all user inputs
   - Sanitize file paths
   - Check for command injection risks

3. **File Operations**:
   - Only write to isolated workspace directories
   - Respect the `DRY_RUN` variable
   - Always check file permissions before reading

### Documentation Standards

1. **Script Headers**: Each script should have:
   ```bash
   #!/data/data/com.termux/files/usr/bin/bash
   #
   # script_name.sh
   # Brief description of what the script does.
   #
   # Usage: ./script_name.sh [options]
   #
   # Safety:
   # - Description of safety guarantees
   # - Non-destructive behaviors
   #
   ```

2. **Inline Comments**: Explain the "why", not the "what"
   ```bash
   # Good
   # OpenAI requires streaming to be explicitly enabled
   streaming=true

   # Bad
   # Set streaming to true
   streaming=true
   ```

3. **User-Facing Documentation**: Update README.md for new features

## Testing

### Running Tests

Always run the test suite before submitting:

```bash
bash tests.sh
```

### Writing Tests

When adding new features, include tests:

```bash
test_new_feature() {
    local result
    result=$(your_function "test_input")
    local code=$?

    if [[ "$code" -eq 0 && "$result" == "expected_output" ]]; then
        pass "Feature works correctly"
    else
        fail "Feature failed: $result"
    fi
}
```

### Test Coverage

We aim for tests that cover:
- Happy path scenarios
- Error conditions
- Edge cases
- Security validations

## Pull Request Process

### Before Submitting

1. **Update from upstream**:
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Run tests**:
   ```bash
   bash tests.sh
   ```

3. **Check your changes**:
   ```bash
   git diff upstream/main
   ```

### PR Checklist

- [ ] Code follows the style guidelines
- [ ] All tests pass
- [ ] New tests added for new features
- [ ] Documentation updated
- [ ] Commit messages are clear and descriptive
- [ ] No merge conflicts
- [ ] PR description explains the changes

### PR Description Template

```markdown
## Description
Brief description of what this PR does

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Performance improvement
- [ ] Security fix

## Testing
Describe how you tested your changes

## Checklist
- [ ] Tests pass
- [ ] Documentation updated
- [ ] Code follows style guidelines
```

### Commit Messages

Follow conventional commit format:

```
type(scope): brief description

Longer explanation if needed.

Fixes #123
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `test`: Adding tests
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `chore`: Maintenance tasks

Examples:
```
feat(ai_cli): add support for custom temperature parameter

fix(url_summarize): handle URLs with special characters

docs(README): add troubleshooting section for API errors
```

## Reporting Bugs

### Before Reporting

1. Check if the bug has already been reported
2. Test with the latest version
3. Verify it's not a configuration issue

### Bug Report Template

```markdown
**Describe the bug**
A clear description of what the bug is.

**To Reproduce**
Steps to reproduce:
1. Run command '...'
2. With input '....'
3. See error

**Expected behavior**
What you expected to happen.

**Actual behavior**
What actually happened.

**Environment**
- Termux version:
- Android version:
- Script version:
- Provider (OpenAI/Gemini):

**Additional context**
Any other relevant information.
```

## Suggesting Features

### Feature Request Template

```markdown
**Is your feature request related to a problem?**
A clear description of the problem.

**Describe the solution you'd like**
How you envision the feature working.

**Describe alternatives you've considered**
Other approaches you've thought about.

**Additional context**
Any other relevant information, mockups, or examples.
```

## Development Tips

### Debugging

1. Enable verbose output:
   ```bash
   bash -x ./ai_cli.sh -p "test"
   ```

2. Check logs:
   ```bash
   tail -f ~/.cache/termux-ai/run.log
   ```

3. Test with dry-run:
   ```bash
   DRY_RUN=1 bash ./script.sh
   ```

### Testing with Mock APIs

Create mock scripts for testing without API calls:

```bash
mkdir -p mock_bin
cat > mock_bin/curl <<'EOF'
#!/bin/bash
echo '{"choices":[{"delta":{"content":"Mock response"}}]}'
EOF
chmod +x mock_bin/curl
export PATH="$(pwd)/mock_bin:$PATH"
```

## Getting Help

- Open an issue for questions
- Check existing issues and documentation
- Review the code - it's heavily commented!

## Recognition

Contributors will be acknowledged in:
- README.md acknowledgments section
- Release notes for their contributions
- GitHub contributor graph

---

Thank you for contributing to Termux AI Toolkit! Your efforts help make AI more accessible to everyone.
