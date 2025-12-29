#!/usr/bin/env bash
#
# postCreateCommand.sh
# Setup script run after devcontainer is created
#

set -e

echo "🚀 Setting up Termux AI Toolkit development environment..."

# Install dependencies
echo "📦 Installing dependencies..."
sudo apt-get update
sudo apt-get install -y curl jq shellcheck

# Make all scripts executable
echo "🔧 Making scripts executable..."
chmod +x *.sh agents/*.sh scripts/*.sh 2>/dev/null || true

# Run initial checks
echo "✅ Running environment checks..."
bash 00_check_env.sh || echo "Note: API keys not configured (expected in dev environment)"

# Run tests to verify everything works
echo "🧪 Running test suite..."
make test || echo "Note: Some tests may fail without API keys (expected)"

echo ""
echo "✨ Development environment ready!"
echo ""
echo "Quick start commands:"
echo "  make help       - See all available make targets"
echo "  make dev-check  - Run linting and tests"
echo "  make test       - Run test suite"
echo "  bash termux-ai --help  - See toolkit usage"
echo ""
