# ADR-0004: GitHub Codespaces as Primary Development Environment

**Date**: 2024-11-15

**Status**: Accepted

**Deciders**: Repository maintainers

**Technical Story**: Enabling mobile-first development workflow for Android users

---

### Context and Problem Statement

Many users want to contribute or develop on Android devices via Termux. However:
- Setting up development tools in Termux can be challenging
- Not all tools are available in Termux
- Testing and debugging is difficult on mobile
- Contributors need consistent development environments

We need a solution that:
- Works from mobile browsers (on Android)
- Provides a full development environment
- Has all necessary tools pre-installed
- Is easy to access and use

### Decision Drivers

* **Mobile accessibility**: Must work from Android Chrome/Firefox
* **Zero setup**: No local installation required
* **Tool availability**: Need shellcheck, prettier, git, etc.
* **Consistency**: Same environment for all contributors
* **Cost**: Should have free tier
* **Integration**: Works with GitHub workflow
* **Performance**: Acceptable for development tasks

### Considered Options

* **GitHub Codespaces** - Cloud-based VS Code environments
* **Gitpod** - Cloud development environments
* **Local Termux setup** - Native Android development
* **Docker containers** - Self-hosted development

### Decision Outcome

Chosen option: **GitHub Codespaces with .devcontainer**, because:
- Free tier for individuals (60 hours/month)
- One-click access from GitHub mobile browser
- VS Code in the browser
- Full Linux environment
- Integrated with GitHub repository
- Supports .devcontainer for consistency

#### Positive Consequences

* **Mobile-friendly**: Click "Code" → "Codespaces" on mobile GitHub
* **Instant setup**: Environment ready in ~2 minutes
* **Full tooling**: shellcheck, prettier, jq, curl all pre-installed
* **Consistent**: Same environment for all developers
* **Integrated**: Terminal, git, extensions all available
* **Cost-effective**: Free tier covers typical usage
* **Professional**: Full VS Code experience

#### Negative Consequences

* **Internet required**: Can't work offline
* **Cost for heavy use**: Beyond free tier (~$0.18/hour)
* **Performance**: Depends on network latency
* **Vendor lock-in**: Tied to GitHub
* **Storage limits**: 20GB base storage

### Implementation Details

Our .devcontainer configuration:
```json
{
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "git": {},
    "node": {"version": "lts"},
    "common-utils": {}
  },
  "postCreateCommand": ".devcontainer/postCreateCommand.sh"
}
```

The `postCreateCommand.sh`:
1. Installs dependencies (curl, jq, shellcheck)
2. Makes scripts executable
3. Runs environment checks
4. Displays quick start guide

### Mobile Development Workflow

For Android users:
1. Open GitHub repository in Chrome
2. Tap "Code" → "Codespaces" → "Create codespace"
3. Wait ~2 minutes for environment setup
4. Get full VS Code in browser with all tools
5. Make changes, test, commit, push
6. Close codespace when done (auto-stops after 30 min idle)

### Local Alternative

Advanced users can still use local Termux:
```bash
# Clone repo
git clone https://github.com/warrenet/termux-ai-toolkit.git
cd termux-ai-toolkit

# Install dependencies
pkg install curl jq git

# Run tests
make test
```

But Codespaces is recommended for most users.

### Cost Management

Free tier limits:
- 60 hours/month core hours
- 15 GB-months storage

Tips to stay in free tier:
- Stop codespace when not actively using (auto-stops after 30 min)
- Delete old codespaces
- Use prebuild for faster startup

### Links

* Implements: .devcontainer/devcontainer.json
* Related: .vscode configuration for tasks and extensions
* Alternative: Local Termux development still supported
