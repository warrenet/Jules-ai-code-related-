#!/bin/bash
#
# Run tests with coverage measurement
# Requires: kcov
#
# Usage: bash scripts/run_with_coverage.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
COVERAGE_DIR="$REPO_ROOT/coverage"

echo "Running tests with coverage measurement..."
echo ""

# Check if kcov is installed
if ! command -v kcov &> /dev/null; then
    echo "⚠️  kcov not found. Please install it:"
    echo ""
    echo "  Ubuntu/Debian: sudo apt-get install kcov"
    echo "  macOS: brew install kcov"
    echo "  Build from source: https://github.com/SimonKagstrom/kcov"
    echo ""
    exit 1
fi

# Create coverage directory
mkdir -p "$COVERAGE_DIR"

# Run tests with kcov
echo "Running tests with kcov..."
cd "$REPO_ROOT"
kcov --exclude-pattern=/usr/include "$COVERAGE_DIR" bash tests.sh

echo ""
echo "✅ Coverage report generated!"
echo ""
echo "View the report:"
echo "  Open: $COVERAGE_DIR/index.html"
echo ""

# Check if we can open the browser
if command -v xdg-open &> /dev/null; then
    echo "Opening coverage report in browser..."
    xdg-open "$COVERAGE_DIR/index.html" &
elif command -v open &> /dev/null; then
    echo "Opening coverage report in browser..."
    open "$COVERAGE_DIR/index.html" &
else
    echo "Coverage report saved to: $COVERAGE_DIR/"
fi
