# GitHub Copilot Instructions for Termux AI Toolkit

## Repository Purpose

The Termux AI Toolkit is a collection of privacy-focused Bash scripts and tools that bring AI capabilities to Android devices via Termux. The repository contains:

1. **Termux AI Command-Line Tools** - Bash scripts for AI interactions on Android/Termux
2. **Agent Builder Web Application** - Browser-based visual tool for creating AI agent prompts
3. **Multi-Agent Workflow System** - Advanced framework coordinating specialized AI agents
4. **Vague Prompt Detection & Improvement** - Intelligent system that automatically improves unclear prompts

## Core Principles

### Safety and Privacy First
- **Non-destructive by default**: All scripts use `DRY_RUN=1` by default
- **Privacy-focused**: Scripts run locally, user controls all data
- **API key protection**: Never log, commit, or expose API keys
- **Isolated workspace**: Only write to dedicated toolkit directories (`~/.local/share/termux-ai/`, `~/.cache/termux-ai/`)
- **No auto-install**: Never automatically install packages or modify system without explicit user consent

### Simplicity and Transparency
- **Pure Bash**: Prefer Bash-native solutions over external commands
- **Minimal dependencies**: Only `curl` and `jq` required
- **Heavily commented**: Explain the "why", not just the "what"
- **No magic**: Clear, auditable implementation

### Unix Philosophy
- **Do one thing well**: Each script has a single, clear purpose
- **Composable**: Scripts should work with pipes and standard Unix tools
- **Text-based**: Work with standard input/output streams

## Technologies Used

### Core Technologies
- **Bash**: Version 4.0+ (Termux-compatible)
- **curl**: HTTP client for API calls
- **jq**: JSON parsing and manipulation
- **Termux:API**: Optional Android integration (clipboard, widgets)

### Web Application
- **HTML5/CSS3**: Vanilla JavaScript (no frameworks)
- **Tailwind CSS**: Styling
- **SortableJS**: Drag-and-drop functionality
- **Firebase**: Optional cloud storage (Firestore, Anonymous Auth)

### Testing
- **Bash test framework**: Custom test suite in `tests.sh`
- **ShellCheck**: Static analysis for shell scripts
- **Pre-commit hooks**: Automated quality checks

## Coding Standards

### Bash Scripts

#### File Header
Every Bash script should start with:
```bash
#!/data/data/com.termux/files/usr/bin/bash
#
# script_name.sh
# Brief description of what the script does.
#
# Usage: ./script_name.sh [options]
#
# Safety:
# - Non-destructive by default (DRY_RUN=1)
# - Only writes to ~/.local/share/termux-ai/
# - API keys never logged
#

# --- Strict Mode ---
set -Eeuo pipefail
IFS=$'\n\t'
```

#### Variable Naming
- **UPPERCASE**: Constants and environment variables (`API_ENDPOINT`, `DRY_RUN`)
- **lowercase**: Local variables and function arguments (`user_input`, `model_name`)
- **snake_case**: Function names (`check_dependencies`, `make_api_call`)

#### Error Handling
Always use robust error handling:
```bash
die() {
    echo "ERROR: $1" >&2
    exit 1
}

require_cmd() {
    command -v "$1" >/dev/null || die "Required command '$1' not found"
}
```

#### API Key Security
- Mask API keys in all output: `${API_KEY:0:8}****`
- Never include keys in error messages or logs
- Use environment variables, never hardcode
- Check `.gitignore` includes config files

### JavaScript/HTML

#### Web Application Code
- Use vanilla JavaScript (no jQuery or frameworks)
- Prefer modern ES6+ syntax
- Use meaningful variable names
- Add comments for complex logic
- Keep Firebase config separate and gitignored

### Documentation

#### Comments in Code
- Explain WHY, not WHAT
- Document edge cases and assumptions
- Mark complex algorithms clearly
- Use section headers: `# --- Section Name ---`

#### User Documentation
- Update README.md for new features
- Include usage examples
- Document prerequisites and dependencies
- Provide troubleshooting steps

## Testing Requirements

### Running Tests
Before any commit, always run:
```bash
bash tests.sh
```

### Writing Tests
For new features, add tests following this pattern:
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
Ensure tests cover:
- Happy path scenarios
- Error conditions
- Edge cases (empty input, special characters, very large input)
- Security validations (API key protection, input sanitization)

## Common Patterns and Workflows

### Adding a New AI Provider
1. Add API key variable to `01_env_template.sh`
2. Create provider function in `ai_cli.sh`:
   ```bash
   provider_name_call() {
       local prompt="$1" system_prompt="$2" model="$3" api_key="$4"
       # Implementation with streaming support
   }
   ```
3. Add detection logic in main()
4. Update documentation
5. Add tests

### Adding a New Command
1. Create script (e.g., `new_feature.sh`)
2. Make it executable: `chmod +x new_feature.sh`
3. Add wrapper in `termux-ai` launcher
4. Add test in `tests.sh`
5. Update README.md and ARCHITECTURE.md

### File Operations
- Always check `DRY_RUN` variable before writing files
- Only write to isolated directories:
  - `~/.local/share/termux-ai/out/` - AI responses
  - `~/.cache/termux-ai/run.log` - Execution logs
- Check file permissions before reading
- Provide clear error messages for file issues

### API Interactions
- Use streaming when possible for better UX
- Implement timeout (default 60 seconds)
- Handle network errors gracefully
- Estimate costs and warn for large inputs (>8000 tokens)
- Support both OpenAI and Gemini providers

## Security Best Practices

### Input Validation
- Validate all user inputs
- Sanitize file paths (check for `..`, absolute paths)
- Prevent command injection (quote variables, avoid eval)
- Check URL validity before fetching

### File System Safety
- Never write outside toolkit directories
- Respect `DRY_RUN` mode
- Check file permissions
- Use `mktemp` for temporary files

### Network Security
- HTTPS only for all API calls
- Verify SSL certificates (curl default)
- Use timeouts to prevent hanging
- No automatic retries (user control)

### Logging and Error Messages
- Never log API keys (mask as `sk-****`)
- Provide helpful error messages
- Include context in errors (what was attempted)
- Use appropriate log levels (INFO, WARN, ERROR)

## Multi-Agent Workflow System

When working with the multi-agent system (`agents/` directory):
- Each agent has a specific role and should stay focused
- Agents communicate via JSON state files
- All state stored in `~/.local/share/termux-ai/workflows/`
- Follow the workflow: Research → Implementation → Verification → Performance Audit → Anomaly Detection
- Document all agent interactions in logs

## Environment Variables

Respect these environment variables:
- `DRY_RUN`: `0` allows file writes, `1` prevents (default: `1`)
- `AI_TIMEOUT`: API request timeout in seconds (default: `60`)
- `PROVIDER`: Force provider - `openai` or `gemini`
- `MODEL_OPENAI`: Default OpenAI model (default: `gpt-4o-mini`)
- `MODEL_GEMINI`: Default Gemini model (default: `gemini-1.5-flash-latest`)
- `OPENAI_API_KEY`: OpenAI API key (required for OpenAI)
- `GEMINI_API_KEY`: Google Gemini API key (required for Gemini)

## Commit Message Format

Follow conventional commits:
```
type(scope): brief description

Longer explanation if needed.

Fixes #123
```

Types: `feat`, `fix`, `docs`, `test`, `refactor`, `perf`, `chore`

Examples:
- `feat(ai_cli): add support for custom temperature parameter`
- `fix(url_summarize): handle URLs with special characters`
- `docs(README): add troubleshooting section for API errors`

## Before Submitting Changes

### Checklist
- [ ] All tests pass (`bash tests.sh`)
- [ ] Code follows style guidelines (ShellCheck clean)
- [ ] Documentation updated (README, ARCHITECTURE if needed)
- [ ] No hardcoded API keys or secrets
- [ ] Commit messages are clear and descriptive
- [ ] No merge conflicts
- [ ] Files are properly executable (`chmod +x` for new scripts)
- [ ] `.gitignore` updated if adding new build artifacts or temp files

### Pre-commit Hook
Use the pre-commit hook for automated checks:
```bash
ln -s ../../scripts/pre-commit-hook.sh .git/hooks/pre-commit
```

Or run manually:
```bash
bash scripts/pre-commit-hook.sh
```

## AI Provider Integration Notes

### OpenAI
- Endpoint: `https://api.openai.com/v1/chat/completions`
- Default model: `gpt-4o-mini`
- Streaming: Set `"stream": true`
- Authentication: `Authorization: Bearer $OPENAI_API_KEY`

### Google Gemini
- Endpoint: `https://generativelanguage.googleapis.com/v1beta/models/{model}:streamGenerateContent`
- Default model: `gemini-1.5-flash-latest`
- Authentication: URL parameter `key=$GEMINI_API_KEY`
- Different JSON structure than OpenAI

## Common Issues to Avoid

### Don't
- ❌ Hardcode API keys in scripts
- ❌ Write files without checking `DRY_RUN`
- ❌ Install packages without user consent
- ❌ Expose API keys in logs or errors
- ❌ Use `eval` or similar dangerous constructs
- ❌ Assume tools are installed (always check first)
- ❌ Break backward compatibility without major version bump
- ❌ Add unnecessary dependencies

### Do
- ✅ Check dependencies with `require_cmd`
- ✅ Validate all inputs
- ✅ Provide clear error messages
- ✅ Use `DRY_RUN` mode by default
- ✅ Mask API keys in output
- ✅ Test on both OpenAI and Gemini (if applicable)
- ✅ Update documentation
- ✅ Add tests for new features

## Performance Considerations

- **Streaming**: Use streaming for real-time feedback
- **Chunking**: For large files, use map-reduce pattern
- **Bash-native**: Prefer parameter expansion over external commands
- **Minimal pipes**: Reduce process creation overhead
- **Caching**: Store API responses when appropriate (respect `DRY_RUN`)

## Custom Agent Profiles

For specialized tasks, leverage these custom agent profiles in `.github/agents/`:

- **bash-expert.md** - Bash scripting, Termux compatibility, and shell best practices
- **documentation-specialist.md** - Technical writing, user guides, and API documentation
- **testing-expert.md** - Test development, TDD practices, and quality assurance
- **security-expert.md** - Secure coding, input validation, and privacy protection
- **multi-agent-specialist.md** - Multi-agent workflows and complex problem-solving

When working on tasks that match these specializations, refer to the appropriate agent profile for detailed guidance and best practices specific to that domain.

## Resources

- [Main README](../README.md) - User documentation
- [Architecture Guide](../ARCHITECTURE.md) - Design decisions and structure
- [Contributing Guide](../CONTRIBUTING.md) - Detailed contribution guidelines
- [Quick Start](../QUICKSTART.md) - 5-minute setup guide
- [Agents README](../agents/AGENTS_README.md) - Multi-agent system documentation
- [Prompt Evaluation](../PROMPT_EVALUATION.md) - Vague prompt detection system

## Questions or Clarifications

When in doubt:
1. Check existing scripts for patterns
2. Review ARCHITECTURE.md for design philosophy
3. Look at tests.sh for testing examples
4. Follow the "safety first" principle
5. Ask for clarification rather than making assumptions

Remember: The toolkit prioritizes user safety, privacy, and transparency above all else.
