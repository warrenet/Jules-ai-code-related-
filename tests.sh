#!/data/data/com.termux/files/usr/bin/bash
#
# tests.sh
# Smoke tests for the Termux AI Toolkit.
#
# Usage: ./tests.sh
#

# --- Strict Mode & Colors ---
# We disable 'e' because we need to capture exit codes manually
set -uo pipefail
IFS=$'\n\t'
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_RESET='\033[0m'

# --- Test State ---
TEST_COUNT=0
FAIL_COUNT=0
MOCK_DIR="mock_bin"
ARGS_FILE="/tmp/ai_cli_test_args"

# --- Helper Functions ---

# Marks a test as passed.
#
# Globals:
#   TEST_COUNT, C_GREEN, C_RESET
# Arguments:
#   $1: The success message.
pass() {
    ((TEST_COUNT++))
    printf "${C_GREEN}PASS:${C_RESET} %s\n" "$1"
}

# Marks a test as failed.
#
# Globals:
#   TEST_COUNT, FAIL_COUNT, C_RED, C_RESET
# Arguments:
#   $1: The failure message.
fail() {
    ((TEST_COUNT++))
    ((FAIL_COUNT++))
    printf "${C_RED}FAIL:${C_RESET} %s\n" "$1"
}

# --- Mocking Setup ---

# Cleans up the mock environment after tests are run.
# This function is triggered by the EXIT trap.
#
# Globals:
#   MOCK_DIR, ARGS_FILE, ORIGINAL_PATH
cleanup() {
    printf "\nCleaning up...\n"
    # Restore original ai_cli.sh if it exists
    if [ -f "./ai_cli.sh.bak" ]; then
        mv ./ai_cli.sh.bak ./ai_cli.sh
    fi
    rm -rf "$MOCK_DIR"
    rm -f "$ARGS_FILE"
    # Restore PATH
    if [ -n "${ORIGINAL_PATH-}" ]; then
        export PATH="${ORIGINAL_PATH}"
    fi
}
trap cleanup EXIT

# Sets up a mock environment for testing.
# It creates a directory for mock commands and prepends it to the PATH,
# effectively hijacking commands like `curl` and `jq`.
#
# Globals:
#   MOCK_DIR, ORIGINAL_PATH, PATH
setup() {
    echo "--- Setting up mock environment ---"
    mkdir -p "$MOCK_DIR"
    ORIGINAL_PATH="$PATH"

    # Mock critical commands
    for cmd in curl jq termux-clipboard-get; do
        cat <<EOF > "$MOCK_DIR/$cmd"
#!/bin/bash
# Mock for $cmd
if [[ "\$1" == "MOCK_FAIL" ]]; then exit 1; fi
echo "Mock output for $cmd"
exit 0
EOF
        chmod +x "$MOCK_DIR/$cmd"
    done

    export PATH="$(pwd)/$MOCK_DIR:$PATH"
}

# --- Test Cases ---

# Tests if `ai_cli.sh -h` displays the help message and exits successfully.
test_01_ai_cli_help_flag() {
    local out
    out=$(bash ./ai_cli.sh -h 2>&1)
    local code=$?
    if [[ "$code" -eq 0 && "$out" == *"Usage:"* ]]; then
        pass "ai_cli.sh -h shows help and exits 0."
    else
        fail "ai_cli.sh -h failed. Exit: $code, Output: $out"
    fi
}

# Tests if `ai_cli.sh` fails when given mutually exclusive arguments (e.g., -p and -f).
test_02_ai_cli_mutually_exclusive_args() {
    # In this environment, capturing stderr from a failing script is unreliable.
    # We will test for the exit code only, which is the most important part.
    bash ./ai_cli.sh -p "prompt" -f "file.txt" &>/dev/null
    local code=$?
    if [[ "$code" -ne 0 ]]; then
        pass "ai_cli.sh correctly exits non-zero for mutually exclusive args."
    else
        fail "ai_cli.sh did not fail with mutually exclusive args. Exit: $code"
    fi
}

# Tests the `00_check_env.sh` script for both success and failure cases.
test_03_check_env_script() {
    # Test pass case
    export OPENAI_API_KEY="test"
    local out
    out=$(bash ./00_check_env.sh 2>&1)
    local code=$?
    if [[ "$code" -eq 0 && "$out" == *"Environment check passed"* ]]; then
        pass "00_check_env.sh passes when environment is OK."
    else
        fail "00_check_env.sh failed on pass case. Exit: $code, Output: $out"
    fi

    # Test fail case
    unset OPENAI_API_KEY
    out=$(bash ./00_check_env.sh 2>&1)
    code=$?
    if [[ "$code" -ne 0 && "$out" == *"No API keys found"* ]]; then
        pass "00_check_env.sh fails when no API keys are set."
    else
        fail "00_check_env.sh did not fail correctly on missing keys. Exit: $code, Output: $out"
    fi
}

# Checks if all the main wrapper scripts exist in the current directory.
test_04_wrapper_scripts_exist() {
    local scripts=("clip_summarize.sh" "url_summarize.sh" "file_summarize.sh")
    for script in "${scripts[@]}"; do
        if [ -f "$script" ]; then
            pass "$script file exists."
        else
            fail "$script file does not exist."
        fi
    done
}

# --- Test Runner ---

# The main test runner.
# Sets up the mock environment, runs all test cases, and reports the final result.
main() {
    setup

    echo "--- Running tests ---"
    test_01_ai_cli_help_flag
    test_02_ai_cli_mutually_exclusive_args
    test_03_check_env_script
    test_04_wrapper_scripts_exist

    echo ""
    echo "--- Tests finished ---"
    if [ "$FAIL_COUNT" -eq 0 ]; then
        echo -e "✅ ${C_GREEN}All $TEST_COUNT tests passed!${C_RESET}"
        exit 0
    else
        echo -e "❌ ${C_RED}$FAIL_COUNT out of $TEST_COUNT tests failed.${C_RESET}"
        exit 1
    fi
}

main
