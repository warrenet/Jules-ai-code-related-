#!/bin/bash
#
# Pre-commit hook for Termux AI Toolkit
# Runs quality checks before allowing commits
#
# To install: ln -s ../../scripts/pre-commit-hook.sh .git/hooks/pre-commit

set -e

echo "Running pre-commit checks..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Track if any checks fail
CHECKS_FAILED=0

# Get list of staged shell scripts
STAGED_SH_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.sh$' || true)

# Check 1: ShellCheck on modified shell scripts
if [ -n "$STAGED_SH_FILES" ]; then
    echo -e "${YELLOW}Checking shell scripts with shellcheck...${NC}"
    if command -v shellcheck &> /dev/null; then
        # Use xargs to properly handle newline-separated file list
        if echo "$STAGED_SH_FILES" | xargs -r shellcheck; then
            echo -e "${GREEN}✓ ShellCheck passed${NC}"
        else
            echo -e "${RED}✗ ShellCheck found issues${NC}"
            CHECKS_FAILED=1
        fi
    else
        echo -e "${YELLOW}⚠ shellcheck not found, skipping${NC}"
    fi
fi

# Check 2: Hardcoded secrets detection
echo -e "${YELLOW}Checking for hardcoded secrets...${NC}"
if git diff --cached | grep -E "(sk-[a-zA-Z0-9]{32,}|AIza[a-zA-Z0-9_-]{35})" > /dev/null; then
    echo -e "${RED}✗ Potential API key found in staged changes${NC}"
    echo "Please remove API keys before committing"
    CHECKS_FAILED=1
else
    echo -e "${GREEN}✓ No hardcoded secrets detected${NC}"
fi

# Check 3: Verify shell scripts are executable
if [ -n "$STAGED_SH_FILES" ]; then
    echo -e "${YELLOW}Checking script permissions...${NC}"
    NON_EXECUTABLE=""
    while IFS= read -r script; do
        if [ -n "$script" ] && [ -f "$script" ] && [ ! -x "$script" ]; then
            NON_EXECUTABLE="$NON_EXECUTABLE $script"
        fi
    done <<< "$STAGED_SH_FILES"
    
    if [ -n "$NON_EXECUTABLE" ]; then
        echo -e "${RED}✗ These scripts are not executable:${NC}"
        echo "$NON_EXECUTABLE"
        echo "Run: chmod +x$NON_EXECUTABLE"
        CHECKS_FAILED=1
    else
        echo -e "${GREEN}✓ All shell scripts are executable${NC}"
    fi
fi

# Check 4: JavaScript/HTML formatting (if modified)
STAGED_JS_HTML=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(js|html)$' || true)
if [ -n "$STAGED_JS_HTML" ]; then
    echo -e "${YELLOW}Checking JavaScript/HTML formatting...${NC}"
    if command -v npx &> /dev/null; then
        # Use xargs to properly handle newline-separated file list
        if echo "$STAGED_JS_HTML" | xargs -r npx prettier --check 2>&1 | grep -q "All matched files"; then
            echo -e "${GREEN}✓ JavaScript/HTML formatting correct${NC}"
        else
            echo -e "${YELLOW}⚠ JavaScript/HTML not formatted. Run: npx prettier --write on staged JS/HTML files${NC}"
            # Don't fail on formatting, just warn
        fi
    else
        echo -e "${YELLOW}⚠ prettier not found, skipping formatting check${NC}"
    fi
fi

# Exit with failure if any checks failed
if [ "$CHECKS_FAILED" -eq 1 ]; then
    echo ""
    echo -e "${RED}Pre-commit checks failed. Commit aborted.${NC}"
    echo "Fix the issues above and try again."
    exit 1
fi

echo ""
echo -e "${GREEN}All pre-commit checks passed!${NC}"
exit 0
