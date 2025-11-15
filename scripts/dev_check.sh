#!/usr/bin/env bash
#
# dev_check.sh
# Runs all quality checks locally before committing
#
# Usage: bash scripts/dev_check.sh
#

set -e

echo "🔍 Running development checks..."
echo ""

# Change to repository root
cd "$(dirname "$0")/.."

# Run shellcheck
echo "📝 Running shellcheck..."
if command -v shellcheck >/dev/null 2>&1; then
    # Run shellcheck and capture output
    if shellcheck -S warning *.sh agents/*.sh scripts/*.sh 2>/dev/null; then
        echo "✓ ShellCheck passed (no errors or warnings)"
    else
        echo "⚠️  ShellCheck found warnings or errors (see above)"
        exit 1
    fi
else
    echo "⚠️  shellcheck not installed, skipping"
fi

echo ""

# Run tests
echo "🧪 Running test suite..."
bash tests.sh
echo "✓ All tests passed"

echo ""

# Run prompt evaluation tests
echo "🧪 Running prompt evaluation tests..."
bash tests_prompt_eval.sh
echo "✓ Prompt evaluation tests passed"

echo ""

# Check for hardcoded secrets
echo "🔒 Checking for hardcoded secrets..."
if grep -r "sk-[a-zA-Z0-9]\{32,\}" --exclude-dir=.git --exclude-dir=node_modules . 2>/dev/null; then
    echo "❌ Potential hardcoded OpenAI API key found!"
    exit 1
fi
if grep -r "AIza[a-zA-Z0-9_-]\{35\}" --exclude-dir=.git --exclude-dir=node_modules . 2>/dev/null; then
    echo "❌ Potential hardcoded Google API key found!"
    exit 1
fi
echo "✓ No hardcoded secrets detected"

echo ""
echo "✅ All development checks passed!"
echo ""
echo "You can now commit your changes:"
echo "  git add ."
echo "  git commit -m 'Your commit message'"
echo "  git push"
