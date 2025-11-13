# Security Policy

## Supported Versions

We release patches for security vulnerabilities for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| 1.1.x   | :white_check_mark: |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

**Please do not report security vulnerabilities through public GitHub issues.**

We take security seriously. If you discover a security vulnerability, please report it responsibly:

### Preferred Method: GitHub Security Advisories

1. Go to the [Security tab](https://github.com/warrenet/Jules-ai-code-related-/security/advisories)
2. Click "Report a vulnerability"
3. Fill out the form with:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if you have one)

### Alternative Method: Email

If you prefer, you can email security concerns to the repository maintainer. Please include:

- Type of vulnerability
- Full path to affected source file(s)
- Location of affected code (tag/branch/commit)
- Any special configuration required to reproduce
- Step-by-step instructions to reproduce
- Proof-of-concept or exploit code (if possible)
- Impact of the vulnerability

### What to Expect

- **Acknowledgment**: We'll acknowledge receipt of your report within 48 hours
- **Investigation**: We'll investigate and validate the vulnerability within 7 days
- **Updates**: We'll keep you informed about our progress
- **Disclosure**: We'll coordinate public disclosure with you once a fix is released
- **Credit**: If you wish, we'll credit you in the security advisory

### Security Update Process

When we receive a security bug report:

1. Confirm the vulnerability and determine affected versions
2. Audit code to find similar problems
3. Prepare fixes for all supported versions
4. Release patched versions as quickly as possible
5. Publish a security advisory on GitHub

## Security Best Practices for Users

### API Key Security

**Never commit API keys to your repository:**

```bash
# Bad - API key in code
export OPENAI_API_KEY="sk-actual-key-here"

# Good - Use config file (gitignored)
source ~/.config/termux-ai/env
```

### Recommended Practices

1. **Use the config file**: Store API keys in `~/.config/termux-ai/env` (gitignored)
2. **Rotate keys regularly**: Change your API keys periodically
3. **Set spending limits**: Configure spending limits with your API provider
4. **Monitor usage**: Check your API usage regularly for anomalies
5. **Keep scripts updated**: Run `git pull` regularly to get security fixes
6. **Review before running**: Always review scripts before execution
7. **Use dry-run mode**: Test with `DRY_RUN=1` (default) before enabling writes

### Known Safe Practices

- ✅ All scripts run with `set -Eeuo pipefail` for safety
- ✅ Default `DRY_RUN=1` prevents accidental file writes
- ✅ API keys masked in all log output
- ✅ Scripts only write to isolated toolkit directories
- ✅ No automatic package installation
- ✅ No system modification without explicit user action

### Verifying Script Integrity

Before running scripts, especially `install_toolkit.sh`, you can verify their integrity:

```bash
# View the script content first
curl -sL https://raw.githubusercontent.com/warrenet/Jules-ai-code-related-/main/install_toolkit.sh | less

# Or download and inspect before running
curl -sL https://raw.githubusercontent.com/warrenet/Jules-ai-code-related-/main/install_toolkit.sh > install_toolkit.sh
less install_toolkit.sh
bash install_toolkit.sh
```

## Security Features

### Input Validation

All scripts validate input:
- File paths are sanitized
- API keys are validated (format only, not tested)
- URLs are checked before fetching
- User prompts have length limits

### Sandboxing

Scripts operate in isolated directories:
- Config: `~/.config/termux-ai/`
- Data: `~/.local/share/termux-ai/`
- Cache: `~/.cache/termux-ai/`

No files outside these directories are modified without explicit user action.

### API Security

- Keys sent only to official provider endpoints:
  - OpenAI: `https://api.openai.com/`
  - Google Gemini: `https://generativelanguage.googleapis.com/`
- HTTPS enforced for all API calls
- Timeouts prevent hanging requests
- No telemetry or analytics

## Scope

This security policy applies to:

- All shell scripts (`.sh` files)
- JavaScript Agent Builder (`script.js`, `index.html`)
- Multi-agent workflow system (`agents/` directory)
- Documentation and examples

## Out of Scope

The following are not covered by this security policy:

- Third-party dependencies (curl, jq, Firebase)
- API provider security (OpenAI, Google Gemini)
- User's own API key management
- Android/Termux platform security
- Browser security for Agent Builder

For issues with dependencies, please report to the respective maintainers.

## Updates to This Policy

We may update this security policy from time to time. Check back regularly or watch the repository for notifications.

**Last Updated**: 2025-11-13
