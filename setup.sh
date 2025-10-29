#!/usr/bin/env bash
#
# setup.sh
# Interactive setup wizard for Termux AI Toolkit
#
# This script will guide you through the complete setup process:
# 1. Check and install dependencies
# 2. Configure API keys
# 3. Test the configuration
# 4. Run a demo
#
# Usage: bash setup.sh
#

set -Eeuo pipefail
IFS=$'\n\t'

# --- Colors ---
C_GREEN='\033[0;32m'
C_BLUE='\033[0;34m'
C_YELLOW='\033[0;33m'
C_RED='\033[0;31m'
C_BOLD='\033[1m'
C_RESET='\033[0m'

# --- Directories ---
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$HOME/.config/termux-ai"
DATA_DIR="$HOME/.local/share/termux-ai"
CACHE_DIR="$HOME/.cache/termux-ai"

# --- Helper Functions ---
print_header() {
    echo ""
    echo -e "${C_BLUE}${C_BOLD}═══════════════════════════════════════════════════════${C_RESET}"
    echo -e "${C_BLUE}${C_BOLD}  $1${C_RESET}"
    echo -e "${C_BLUE}${C_BOLD}═══════════════════════════════════════════════════════${C_RESET}"
    echo ""
}

print_step() {
    echo -e "${C_GREEN}▶${C_RESET} ${C_BOLD}$1${C_RESET}"
}

print_success() {
    echo -e "${C_GREEN}✓${C_RESET} $1"
}

print_warning() {
    echo -e "${C_YELLOW}⚠${C_RESET} $1"
}

print_error() {
    echo -e "${C_RED}✗${C_RESET} $1"
}

print_info() {
    echo -e "${C_BLUE}ℹ${C_RESET} $1"
}

ask_yes_no() {
    local prompt="$1"
    local default="${2:-n}"
    local yn

    if [[ "$default" == "y" ]]; then
        prompt="$prompt [Y/n] "
    else
        prompt="$prompt [y/N] "
    fi

    while true; do
        read -p "$prompt" yn
        yn="${yn:-$default}"
        case "$yn" in
            [Yy]*) return 0 ;;
            [Nn]*) return 1 ;;
            *) echo "Please answer yes or no." ;;
        esac
    done
}

# --- Step 1: Welcome ---
welcome() {
    clear
    print_header "Termux AI Toolkit Setup Wizard"

    cat << 'EOF'
Welcome! This wizard will help you set up the Termux AI Toolkit.

The setup process includes:
  1. Installing required dependencies (curl, jq)
  2. Configuring your AI provider (OpenAI or Gemini)
  3. Testing your configuration
  4. Running a quick demo

This will take about 2-3 minutes.

EOF

    if ! ask_yes_no "Ready to begin?" "y"; then
        echo "Setup cancelled. Run 'bash setup.sh' when you're ready."
        exit 0
    fi
}

# --- Step 2: Check Dependencies ---
check_dependencies() {
    print_header "Step 1: Checking Dependencies"

    local missing_deps=()
    local install_cmd=""

    # Detect package manager
    if command -v pkg &> /dev/null; then
        install_cmd="pkg install"
        print_info "Detected Termux package manager"
    elif command -v apt-get &> /dev/null; then
        install_cmd="sudo apt-get install"
        print_info "Detected apt package manager"
    elif command -v yum &> /dev/null; then
        install_cmd="sudo yum install"
        print_info "Detected yum package manager"
    elif command -v brew &> /dev/null; then
        install_cmd="brew install"
        print_info "Detected Homebrew package manager"
    else
        print_warning "Could not detect package manager"
    fi

    # Check for required commands
    for cmd in curl jq; do
        if command -v "$cmd" &> /dev/null; then
            print_success "$cmd is installed"
        else
            print_warning "$cmd is NOT installed"
            missing_deps+=("$cmd")
        fi
    done

    # Install missing dependencies if found
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo ""
        print_step "Missing dependencies: ${missing_deps[*]}"

        if [ -n "$install_cmd" ]; then
            echo ""
            if ask_yes_no "Install missing dependencies now?" "y"; then
                echo ""
                print_step "Installing: ${missing_deps[*]}"
                if $install_cmd "${missing_deps[@]}"; then
                    print_success "Dependencies installed successfully"
                else
                    print_error "Failed to install dependencies"
                    echo ""
                    echo "Please install manually using:"
                    echo "  $install_cmd ${missing_deps[*]}"
                    exit 1
                fi
            else
                print_error "Cannot continue without required dependencies"
                echo ""
                echo "Please install manually using:"
                echo "  $install_cmd ${missing_deps[*]}"
                exit 1
            fi
        else
            print_error "Please install the following manually:"
            for dep in "${missing_deps[@]}"; do
                echo "  - $dep"
            done
            exit 1
        fi
    fi

    # Check for optional Termux:API
    if command -v termux-clipboard-get &> /dev/null; then
        print_success "Termux:API is installed (optional)"
    else
        print_info "Termux:API not found (optional - enables clipboard features)"
    fi

    echo ""
    print_success "All required dependencies are ready!"
    sleep 1
}

# --- Step 3: Configure API Keys ---
configure_api_keys() {
    print_header "Step 2: Configure AI Provider"

    cat << EOF
You need an API key from one of these providers:

  1. OpenAI (ChatGPT)
     - Get key at: https://platform.openai.com/api-keys
     - Free tier available
     - Models: GPT-4o, GPT-4o-mini

  2. Google Gemini
     - Get key at: https://ai.google.dev/
     - Free tier available
     - Models: Gemini 1.5 Pro, Flash

EOF

    # Create config directory
    mkdir -p "$CONFIG_DIR"

    local provider_choice
    echo "Which provider do you want to use?"
    echo "  1) OpenAI"
    echo "  2) Google Gemini"
    echo "  3) Skip for now (configure manually later)"
    echo ""

    while true; do
        read -p "Enter choice [1-3]: " provider_choice
        case "$provider_choice" in
            1|2|3) break ;;
            *) echo "Please enter 1, 2, or 3" ;;
        esac
    done

    if [ "$provider_choice" == "3" ]; then
        print_info "Skipping API key configuration"
        print_info "You can configure later by editing: $CONFIG_DIR/env"
        echo ""

        # Create minimal config
        if [ ! -f "$CONFIG_DIR/env" ]; then
            cp "$SCRIPT_DIR/01_env_template.sh" "$CONFIG_DIR/env"
            print_info "Created config template at: $CONFIG_DIR/env"
        fi
        return 0
    fi

    echo ""

    # Get API key
    local api_key
    if [ "$provider_choice" == "1" ]; then
        print_step "OpenAI API Key Setup"
        echo ""
        echo "Your API key should start with 'sk-'"
        echo "Paste your OpenAI API key (input will be hidden):"
        read -s api_key

        if [[ ! "$api_key" =~ ^sk- ]]; then
            print_warning "API key doesn't look like an OpenAI key (should start with 'sk-')"
            if ! ask_yes_no "Continue anyway?" "n"; then
                configure_api_keys
                return
            fi
        fi

        # Create config file
        cat > "$CONFIG_DIR/env" << EOCONF
#!/usr/bin/env bash
# Termux AI Toolkit Configuration
# Generated by setup wizard on $(date)

# OpenAI Configuration
export OPENAI_API_KEY="$api_key"
export MODEL_OPENAI="gpt-4o-mini"

# Default Settings
export DRY_RUN=0
export AI_TIMEOUT=60
EOCONF

    else
        print_step "Google Gemini API Key Setup"
        echo ""
        echo "Your API key should start with 'AIza'"
        echo "Paste your Gemini API key (input will be hidden):"
        read -s api_key

        if [[ ! "$api_key" =~ ^AIza ]]; then
            print_warning "API key doesn't look like a Gemini key (should start with 'AIza')"
            if ! ask_yes_no "Continue anyway?" "n"; then
                configure_api_keys
                return
            fi
        fi

        # Create config file
        cat > "$CONFIG_DIR/env" << EOCONF
#!/usr/bin/env bash
# Termux AI Toolkit Configuration
# Generated by setup wizard on $(date)

# Google Gemini Configuration
export GEMINI_API_KEY="$api_key"
export MODEL_GEMINI="gemini-1.5-flash-latest"

# Default Settings
export DRY_RUN=0
export AI_TIMEOUT=60
EOCONF
    fi

    chmod 600 "$CONFIG_DIR/env"
    echo ""
    print_success "Configuration saved to: $CONFIG_DIR/env"
    print_info "Your API key is stored securely (file permissions: 600)"
}

# --- Step 4: Test Configuration ---
test_configuration() {
    print_header "Step 3: Testing Configuration"

    # Load config
    if [ -f "$CONFIG_DIR/env" ]; then
        source "$CONFIG_DIR/env"
        print_success "Configuration loaded"
    else
        print_warning "No configuration file found"
        print_info "Skipping test - you can run 'bash 00_check_env.sh' later"
        return 0
    fi

    echo ""
    print_step "Running environment check..."
    echo ""

    if bash "$SCRIPT_DIR/00_check_env.sh"; then
        echo ""
        print_success "Configuration test passed!"
    else
        echo ""
        print_error "Configuration test failed"
        print_info "You may need to check your API key or internet connection"

        if ask_yes_no "Do you want to reconfigure your API key?" "y"; then
            configure_api_keys
            test_configuration
        fi
    fi
}

# --- Step 5: Run Demo ---
run_demo() {
    print_header "Step 4: Quick Demo"

    if ! [ -f "$CONFIG_DIR/env" ]; then
        print_info "Skipping demo - no API key configured"
        return 0
    fi

    source "$CONFIG_DIR/env"

    cat << EOF
Let's test the AI with a simple question!

This will:
  - Send a test prompt to the AI
  - Display the response in real-time
  - Save the output to a file

EOF

    if ! ask_yes_no "Run the demo?" "y"; then
        print_info "Skipping demo"
        return 0
    fi

    echo ""
    print_step "Sending test prompt: 'Explain what AI is in one sentence'"
    echo ""
    echo -e "${C_YELLOW}AI Response:${C_RESET}"
    echo "─────────────────────────────────────────────────"

    cd "$SCRIPT_DIR"
    if bash ai_cli.sh -p "Explain what AI is in one sentence" --no-save; then
        echo ""
        echo "─────────────────────────────────────────────────"
        echo ""
        print_success "Demo completed successfully!"
    else
        echo ""
        print_error "Demo failed"
        print_info "Check your API key and internet connection"
    fi
}

# --- Step 6: Completion ---
show_completion() {
    print_header "Setup Complete!"

    cat << EOF
${C_GREEN}✓${C_RESET} Your Termux AI Toolkit is ready to use!

${C_BOLD}Quick Start Commands:${C_RESET}

  # Ask the AI anything:
  bash ai_cli.sh -p "Your question here"

  # Summarize a URL:
  bash url_summarize.sh -u "https://example.com"

  # Summarize a file:
  bash file_summarize.sh -f /path/to/file.txt

  # Summarize clipboard (requires Termux:API):
  bash clip_summarize.sh

${C_BOLD}Useful Scripts:${C_RESET}

  bash 00_check_env.sh    - Check your configuration
  bash quick_start.sh     - Interactive demo and examples
  bash setup.sh           - Run this wizard again

${C_BOLD}Configuration:${C_RESET}

  Your settings: $CONFIG_DIR/env
  Output files:  $DATA_DIR/out/
  Logs:          $CACHE_DIR/run.log

${C_BOLD}Documentation:${C_RESET}

  README.md              - Full documentation
  README_first.md        - Detailed user guide
  CONTRIBUTING.md        - For contributors

${C_BOLD}Need Help?${C_RESET}

  - Check README.md for examples
  - Run 'bash 00_check_env.sh' to diagnose issues
  - Visit: https://github.com/warrenet/Jules-ai-code-related-

EOF

    print_success "Happy coding with AI!"
}

# --- Main Flow ---
main() {
    welcome
    check_dependencies
    configure_api_keys
    test_configuration
    run_demo
    show_completion
}

main "$@"
