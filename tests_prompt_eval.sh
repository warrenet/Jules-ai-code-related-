#!/data/data/com.termux/files/usr/bin/bash
#
# tests_prompt_eval.sh
# Test suite for prompt evaluation and improvement system
#

set -Eeo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PASS_COUNT=0
FAIL_COUNT=0

pass() {
    echo "PASS: $1"
    ((PASS_COUNT++)) || true
}

fail() {
    echo "FAIL: $1"
    ((FAIL_COUNT++)) || true
}

echo "--- Testing Prompt Evaluation System ---"

# Test 1: Prompt evaluator script exists and is executable
if [[ -x "$SCRIPT_DIR/hooks/prompt_evaluator.sh" ]]; then
    pass "prompt_evaluator.sh exists and is executable"
else
    fail "prompt_evaluator.sh missing or not executable"
fi

# Test 2: Prompt improver script exists and is executable
if [[ -x "$SCRIPT_DIR/skills/prompt_improver.sh" ]]; then
    pass "prompt_improver.sh exists and is executable"
else
    fail "prompt_improver.sh missing or not executable"
fi

# Test 3: Prompt evaluator shows help
if timeout 5 bash "$SCRIPT_DIR/hooks/prompt_evaluator.sh" --help 2>&1 | grep -q "Prompt Evaluator"; then
    pass "prompt_evaluator.sh --help works"
else
    fail "prompt_evaluator.sh --help failed"
fi

# Test 4: Prompt improver shows help
if timeout 5 bash "$SCRIPT_DIR/skills/prompt_improver.sh" --help 2>&1 | grep -q "Prompt Improver"; then
    pass "prompt_improver.sh --help works"
else
    fail "prompt_improver.sh --help failed"
fi

# Test 5: Prompt evaluator requires prompt argument
OUTPUT=$(timeout 5 bash "$SCRIPT_DIR/hooks/prompt_evaluator.sh" --api-key "test" 2>&1 || true)
if echo "$OUTPUT" | grep -q "required"; then
    pass "prompt_evaluator.sh validates required prompt argument"
else
    fail "prompt_evaluator.sh should require prompt argument"
fi

# Test 6: Prompt improver requires prompt argument
OUTPUT=$(timeout 5 bash "$SCRIPT_DIR/skills/prompt_improver.sh" --api-key "test" 2>&1 || true)
if echo "$OUTPUT" | grep -q "required"; then
    pass "prompt_improver.sh validates required prompt argument"
else
    fail "prompt_improver.sh should require prompt argument"
fi

# Test 7: Check ai_cli.sh has been updated with evaluation logic
if grep -q "Prompt Evaluation Hook" "$SCRIPT_DIR/ai_cli.sh"; then
    pass "ai_cli.sh includes prompt evaluation hook"
else
    fail "ai_cli.sh missing prompt evaluation hook"
fi

# Test 8: Check environment template has PROMPT_EVALUATION variable
if grep -q "PROMPT_EVALUATION" "$SCRIPT_DIR/01_env_template.sh"; then
    pass "01_env_template.sh includes PROMPT_EVALUATION variable"
else
    fail "01_env_template.sh missing PROMPT_EVALUATION variable"
fi

# Test 9: Check ai_cli.sh help mentions prompt evaluation
if timeout 5 bash "$SCRIPT_DIR/ai_cli.sh" --help 2>&1 | grep -q "PROMPT_EVALUATION"; then
    pass "ai_cli.sh --help documents PROMPT_EVALUATION"
else
    fail "ai_cli.sh --help should document PROMPT_EVALUATION"
fi

echo ""
echo "--- Test Summary ---"
echo "Passed: $PASS_COUNT"
if [[ $FAIL_COUNT -gt 0 ]]; then
    echo "Failed: $FAIL_COUNT"
    exit 1
else
    echo "✅ All tests passed!"
    exit 0
fi
