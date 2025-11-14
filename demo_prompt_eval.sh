#!/data/data/com.termux/files/usr/bin/bash
#
# demo_prompt_eval.sh
# Demonstration of the vague prompt detection and improvement system
#

set -Eeo pipefail

echo "======================================"
echo "Prompt Evaluation System Demo"
echo "======================================"
echo ""
echo "This demo shows how the system works without making actual API calls."
echo ""

# Demo 1: Vague prompt detection
echo "--- Demo 1: Evaluating a VAGUE prompt ---"
echo "Prompt: 'fix the bug'"
echo ""
echo "Expected behavior:"
echo "  1. System detects prompt is vague"
echo "  2. Invokes prompt-improver skill"
echo "  3. Researches project context"
echo "  4. Generates clarifying questions"
echo "  5. Asks user for answers"
echo ""

# Demo 2: Clear prompt detection
echo "--- Demo 2: Evaluating a CLEAR prompt ---"
echo "Prompt: 'Fix the null pointer exception in user_service.py line 42'"
echo ""
echo "Expected behavior:"
echo "  1. System detects prompt is clear"
echo "  2. Proceeds immediately without questions"
echo "  3. No additional API calls needed"
echo ""

# Demo 3: Disabling evaluation
echo "--- Demo 3: Disabling evaluation ---"
echo "Command: PROMPT_EVALUATION=0 bash ai_cli.sh -p 'fix the bug'"
echo ""
echo "Expected behavior:"
echo "  1. Evaluation is skipped"
echo "  2. Prompt sent directly to AI"
echo "  3. Useful for batch processing or when user knows prompt is adequate"
echo ""

echo "======================================"
echo "Run with actual API key:"
echo "======================================"
echo ""
echo "Example 1 - Test with vague prompt:"
echo "  bash ai_cli.sh -p 'fix the bug'"
echo ""
echo "Example 2 - Test with clear prompt:"
echo "  bash ai_cli.sh -p 'Add error handling to openai_call function in ai_cli.sh'"
echo ""
echo "Example 3 - Skip evaluation:"
echo "  PROMPT_EVALUATION=0 bash ai_cli.sh -p 'fix the bug'"
echo ""
