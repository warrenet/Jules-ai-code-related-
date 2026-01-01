# Deployment Guide

This guide covers deploying and running the Termux AI Toolkit in various environments.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Android/Termux Deployment](#androidtermux-deployment)
3. [GitHub Codespaces](#github-codespaces)
4. [Development Environment](#development-environment)
5. [CI/CD Pipeline](#cicd-pipeline)
6. [Releases](#releases)
7. [Troubleshooting](#troubleshooting)

---

## Quick Start

The fastest way to get started depends on your platform:

### On Android (Termux)

```bash
# Install from GitHub
curl -sL https://raw.githubusercontent.com/warrenet/termux-ai-toolkit/main/install_toolkit.sh | bash

# Configure API key
mkdir -p ~/.config/termux-ai
cp 01_env_template.sh ~/.config/termux-ai/env
nano ~/.config/termux-ai/env  # Add your API key

# Test it
bash termux-ai ask -p "Hello, AI!"
```

### On Desktop/Server (Linux/macOS)

```bash
# Clone repository
git clone https://github.com/warrenet/termux-ai-toolkit.git
cd termux-ai-toolkit

# Install dependencies
make install

# Configure
mkdir -p ~/.config/termux-ai
cp 01_env_template.sh ~/.config/termux-ai/env
nano ~/.config/termux-ai/env  # Add your API key

# Run tests
make test

# Use the toolkit
bash termux-ai --help
```

### In GitHub Codespaces (Recommended for Development)

1. Go to https://github.com/warrenet/termux-ai-toolkit
2. Click "Code" → "Codespaces" → "Create codespace on main"
3. Wait ~2 minutes for environment setup
4. Everything is pre-configured and ready!

---

## Android/Termux Deployment

### Prerequisites

1. Install [Termux from F-Droid](https://f-droid.org/en/packages/com.termux/)
   - **Important**: Don't use Play Store version (outdated)
   
2. Update Termux packages:
   ```bash
   pkg update && pkg upgrade
   ```

### Installation

#### Option 1: One-Line Install (Recommended)

```bash
curl -sL https://raw.githubusercontent.com/warrenet/termux-ai-toolkit/main/install_toolkit.sh | bash
```

This script:
- Installs dependencies (curl, jq)
- Clones the repository
- Makes scripts executable
- Creates config directory
- Runs environment check

#### Option 2: Manual Install

```bash
# Install dependencies
pkg install curl jq git

# Clone repository
git clone https://github.com/warrenet/termux-ai-toolkit.git ~/termux-ai-toolkit
cd ~/termux-ai-toolkit

# Make scripts executable
chmod +x *.sh agents/*.sh scripts/*.sh

# Verify installation
bash 00_check_env.sh
```

### Configuration

1. Create config directory:
   ```bash
   mkdir -p ~/.config/termux-ai
   ```

2. Copy template:
   ```bash
   cp 01_env_template.sh ~/.config/termux-ai/env
   ```

3. Edit config:
   ```bash
   nano ~/.config/termux-ai/env
   ```

4. Add your API key:
   ```bash
   # For OpenAI
   export OPENAI_API_KEY="sk-your-key-here"
   
   # OR for Google Gemini
   export GEMINI_API_KEY="your-gemini-key-here"
   ```

5. Load config:
   ```bash
   source ~/.config/termux-ai/env
   ```

6. Add to shell startup (optional):
   ```bash
   echo 'source ~/.config/termux-ai/env' >> ~/.bashrc
   ```

### Optional Features

#### Termux:API Integration

For clipboard access and widgets:

```bash
# Install Termux:API app from F-Droid
# Then install the package:
pkg install termux-api

# Test clipboard
echo "test" | termux-clipboard-set
termux-clipboard-get
```

#### Home Screen Widgets

See [optional_widget_setup.md](optional_widget_setup.md) for widget configuration.

---

## GitHub Codespaces

### Why Codespaces?

- ✅ Works from mobile browsers (Android Chrome/Firefox)
- ✅ Full VS Code environment
- ✅ Pre-configured with all tools
- ✅ Free tier: 60 hours/month
- ✅ No local installation needed

### Creating a Codespace

1. **From Desktop/Mobile Browser**:
   - Go to repository: https://github.com/warrenet/termux-ai-toolkit
   - Click green "Code" button
   - Select "Codespaces" tab
   - Click "Create codespace on main"

2. **Wait for Setup** (~2 minutes):
   - Environment builds automatically
   - Dependencies install
   - Scripts become executable
   - Tests run to verify setup

3. **Start Coding**:
   - Full VS Code in browser
   - Terminal with all tools
   - Git integration
   - Extensions pre-installed

### Using Codespaces

#### Quick Commands

```bash
# Run all quality checks
make dev-check

# Run tests
make test

# Lint code
make lint

# Format code
make format

# Use the toolkit
bash termux-ai ask -p "Hello from Codespaces!"
```

#### VS Code Tasks

Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac) and type "Tasks":

- **Development Check** - Run lint + test
- **Run Tests** - Execute test suite
- **Lint Scripts** - Check code quality
- **Format Code** - Format JS/HTML

### Cost Management

Free tier limits:
- **Core hours**: 60/month for 2-core machine
- **Storage**: 15 GB-months

Tips to stay free:
- Codespace auto-stops after 30 minutes idle
- Delete old codespaces: Settings → Codespaces
- Use 2-core machine (default)

---

## Development Environment

### Local Setup

```bash
# Clone repository
git clone https://github.com/warrenet/termux-ai-toolkit.git
cd termux-ai-toolkit

# Install dependencies
make install
# Or manually:
# Linux/Ubuntu: sudo apt-get install curl jq shellcheck
# macOS: brew install curl jq shellcheck
# Termux: pkg install curl jq

# Install Node.js (optional, for prettier)
# Ubuntu: sudo apt-get install nodejs npm
# macOS: brew install node
# Termux: pkg install nodejs-lts

# Run development checks
make dev-check
```

### Development Workflow

1. **Make changes** to scripts

2. **Run quality checks**:
   ```bash
   make dev-check
   # Or:
   bash scripts/dev_check.sh
   ```

3. **Test your changes**:
   ```bash
   make test
   ```

4. **Format code** (if you modified HTML/JS):
   ```bash
   make format
   ```

5. **Commit and push**:
   ```bash
   git add .
   git commit -m "Your change description"
   git push
   ```

### Pre-commit Hook (Optional)

Install the pre-commit hook for automatic checks:

```bash
ln -s ../../scripts/pre-commit-hook.sh .git/hooks/pre-commit
```

Now git will automatically check your code before each commit.

---

## CI/CD Pipeline

### GitHub Actions Workflows

The repository includes three workflows:

#### 1. CI Tests (`.github/workflows/test.yml`)

**Triggers**: Push to main/develop, Pull requests

**Steps**:
1. Checkout code
2. Install dependencies (curl, jq, optional kcov)
3. Make scripts executable
4. Run environment check
5. Run test suite
6. Run shellcheck on all scripts
7. Verify installer integrity
8. Upload coverage reports

**Status**: Should pass on all platforms (kcov is optional)

#### 2. CodeQL Security Scan (`.github/workflows/codeql.yml`)

**Triggers**: Push to main/develop, PRs, Weekly schedule

**Steps**:
1. Checkout code
2. Initialize CodeQL (JavaScript analysis)
3. Auto-build
4. Analyze for security vulnerabilities

**Status**: Monitors JavaScript in Agent Builder

#### 3. Release Workflow (`.github/workflows/release.yml`)

**Triggers**: Manual workflow dispatch

**Steps**:
1. Validate version format
2. Generate changelog
3. Create git tag
4. Create GitHub Release
5. Upload release notes

**Usage**:
```bash
# Via GitHub web UI:
# Actions → Release → Run workflow → Enter version (e.g., 1.1.0)

# Or via gh CLI:
gh workflow run release.yml -f version=1.1.0
```

### Local CI Simulation

Run the same checks that CI runs:

```bash
# Full dev check (lint + test)
make dev-check

# Just shellcheck
make lint

# Just tests
make test

# Or run the CI script directly
bash scripts/dev_check.sh
```

---

## Releases

Follow this checklist before cutting a release to ensure consistency and quality:

1. **Bump the version**
   - Update `package.json` and any release scripts to the new semantic version.
   - Confirm change logs or release notes reflect the new version.

2. **Run quality checks locally**
   - `make test` — ensure the full suite passes.
   - `make lint` — verify all scripts pass linting.

3. **Validate installer integrity**
   - Execute `bash install_toolkit.sh` in a clean environment (or container) and confirm the toolkit installs and runs `00_check_env.sh` successfully.

4. **Prepare Git tags and GitHub Release**
   - Create an annotated tag matching the bumped version (e.g., `git tag -a v1.2.0 -m "Release v1.2.0"`).
   - Push tags (`git push origin --tags`).
   - Draft a GitHub Release that links the new tag and includes highlights, breaking changes, and installation notes.

5. **Verify GitHub Codespaces setup**
   - Launch a Codespace from the target branch.
   - Confirm the devcontainer completes setup without errors and `make dev-check` (or at least `make test`/`make lint`) succeeds inside the Codespace.

6. **Publish and monitor**
   - Publish the GitHub Release.
   - Monitor initial installs (especially via `install_toolkit.sh`) for issues and update release notes if hotfixes are needed.

This checklist pairs with the automated release workflow (`.github/workflows/release.yml`); use it to catch issues early and ensure releases remain reproducible.

---

## Troubleshooting

### Common Issues

#### Issue: `kcov not available`

**Solution**: This is expected on Ubuntu 24.04+. The CI workflow handles this gracefully. Coverage collection is skipped, but tests still run.

#### Issue: `shellcheck: command not found`

**Solution**: 
```bash
# Ubuntu/Debian
sudo apt-get install shellcheck

# macOS
brew install shellcheck

# Termux
pkg install shellcheck
```

#### Issue: `make: command not found`

**Solution**: Use bash directly:
```bash
bash tests.sh      # Instead of: make test
bash scripts/dev_check.sh  # Instead of: make dev-check
```

#### Issue: API key not found

**Solution**:
1. Verify config exists: `cat ~/.config/termux-ai/env`
2. Load config: `source ~/.config/termux-ai/env`
3. Check variable: `echo $OPENAI_API_KEY` or `echo $GEMINI_API_KEY`
4. Run check: `bash 00_check_env.sh`

#### Issue: Scripts not executable

**Solution**:
```bash
chmod +x *.sh agents/*.sh scripts/*.sh
```

#### Issue: Codespace fails to build

**Solution**:
1. Delete the codespace
2. Create a new one
3. If still fails, check `.devcontainer/devcontainer.json` for errors

### Getting Help

1. **Check existing documentation**:
   - README.md
   - ARCHITECTURE.md
   - docs/ADR-*.md

2. **Run diagnostic**:
   ```bash
   bash 00_check_env.sh
   ```

3. **Check CI logs**:
   - Go to Actions tab on GitHub
   - Check failed workflow runs

4. **Open an issue**:
   - Provide error message
   - Include output of `bash 00_check_env.sh`
   - Specify platform (Termux/Linux/macOS/Codespaces)

---

## Production Checklist

Before deploying to production:

- [ ] All tests pass: `make test`
- [ ] ShellCheck passes: `make lint`
- [ ] Environment check passes: `bash 00_check_env.sh`
- [ ] API keys configured
- [ ] DRY_RUN mode tested
- [ ] Actual API calls tested (with DRY_RUN=0)
- [ ] GitHub Actions workflows passing
- [ ] Security scan (CodeQL) clean
- [ ] Documentation up to date
- [ ] Changelog updated

## Deployment Verification

After deployment:

1. **Run quick smoke test**:
   ```bash
   bash termux-ai --version
   bash termux-ai --help
   bash 00_check_env.sh
   ```

2. **Test core functionality**:
   ```bash
   # Ask a simple question
   bash termux-ai ask -p "What is 2+2?"
   
   # Check environment
   bash 00_check_env.sh
   ```

3. **Verify files are in place**:
   ```bash
   ls -la *.sh
   ls -la agents/
   ls -la ~/.config/termux-ai/
   ```

4. **Check permissions**:
   ```bash
   # All .sh files should be executable
   ls -l *.sh agents/*.sh scripts/*.sh
   ```

---

## Next Steps

- Explore [ARCHITECTURE.md](ARCHITECTURE.md) for technical details
- Read [CONTRIBUTING.md](CONTRIBUTING.md) to contribute
- Check [docs/](docs/) for Architecture Decision Records
- See [optional_widget_setup.md](optional_widget_setup.md) for widgets

---

**Ready to deploy? Start with the [Quick Start](#quick-start) section!**
