#!/usr/bin/env bash
#
# install_deps.sh
# Install all required dependencies for development
#
# Usage: bash scripts/install_deps.sh
#

set -e

echo "📦 Installing Termux AI Toolkit dependencies..."
echo ""

# Detect package manager
if command -v pkg >/dev/null 2>&1; then
    PKG_MGR="pkg"
    echo "Detected Termux environment"
elif command -v apt-get >/dev/null 2>&1; then
    PKG_MGR="apt-get"
    echo "Detected Debian/Ubuntu environment"
else
    echo "❌ Error: No supported package manager found (pkg or apt-get)"
    exit 1
fi

echo "Package manager: $PKG_MGR"
echo ""

# Update package list
echo "Updating package list..."
if [ "$PKG_MGR" = "pkg" ]; then
    pkg update
elif [ "$PKG_MGR" = "apt-get" ]; then
    sudo apt-get update
fi

echo ""

# Install core dependencies
echo "Installing core dependencies (curl, jq, git)..."
if [ "$PKG_MGR" = "pkg" ]; then
    pkg install -y curl jq git
elif [ "$PKG_MGR" = "apt-get" ]; then
    sudo apt-get install -y curl jq git
fi

echo ""

# Install shellcheck (for linting)
echo "Installing shellcheck (optional, for linting)..."
if [ "$PKG_MGR" = "pkg" ]; then
    pkg install -y shellcheck || echo "⚠️  shellcheck not available in Termux, skipping"
elif [ "$PKG_MGR" = "apt-get" ]; then
    sudo apt-get install -y shellcheck || echo "⚠️  shellcheck not available, skipping"
fi

echo ""

# Install Node.js (optional, for prettier)
echo "Installing Node.js (optional, for prettier formatting)..."
if [ "$PKG_MGR" = "pkg" ]; then
    pkg install -y nodejs-lts || pkg install -y nodejs || echo "⚠️  Node.js not available, skipping"
elif [ "$PKG_MGR" = "apt-get" ]; then
    if ! command -v node >/dev/null 2>&1; then
        echo "Node.js not found. Install manually if you need prettier formatting:"
        echo "  https://nodejs.org/"
    else
        echo "✓ Node.js already installed"
    fi
fi

echo ""
echo "✅ Core dependencies installed successfully!"
echo ""
echo "Installed:"
echo "  - curl (for API calls)"
echo "  - jq (for JSON processing)"  
echo "  - git (for version control)"
echo ""
echo "Optional (if available):"
echo "  - shellcheck (for script linting)"
echo "  - node (for prettier formatting)"
echo ""
echo "Next steps:"
echo "  1. Configure your API key: cp 01_env_template.sh ~/.config/termux-ai/env"
echo "  2. Edit the config: nano ~/.config/termux-ai/env"
echo "  3. Run environment check: bash 00_check_env.sh"
echo "  4. Run tests: bash tests.sh"
