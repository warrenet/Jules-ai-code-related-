#!/usr/bin/env bash
#
# quick_start.sh
# Interactive quick-start guide for Termux AI Toolkit
#
# This script provides hands-on examples and demos to help you
# learn what the toolkit can do.
#
# Usage: bash quick_start.sh
#

set -Eeuo pipefail
IFS=$'\n\t'

# --- Colors ---
C_GREEN='\033[0;32m'
C_BLUE='\033[0;34m'
C_YELLOW='\033[0;33m'
C_CYAN='\033[0;36m'
C_BOLD='\033[1m'
C_RESET='\033[0m'

# --- Directories ---
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$HOME/.config/termux-ai"

# --- Helper Functions ---
print_header() {
    clear
    echo -e "${C_BLUE}${C_BOLD}"
    cat << 'EOF'
╔════════════════════════════════════════════════════════════╗
║         Termux AI Toolkit - Quick Start Guide             ║
╚════════════════════════════════════════════════════════════╝
EOF
    echo -e "${C_RESET}"
}

print_menu_item() {
    echo -e "  ${C_CYAN}$1)${C_RESET} $2"
}

pause() {
    echo ""
    read -p "Press ENTER to continue..."
}

run_example() {
    local title="$1"
    local description="$2"
    local command="$3"

    echo ""
    echo -e "${C_BOLD}${C_YELLOW}Example: $title${C_RESET}"
    echo "$description"
    echo ""
    echo -e "${C_CYAN}Command:${C_RESET} $command"
    echo ""

    if [[ "$command" == *"termux-clipboard-get"* ]] && ! command -v termux-clipboard-get &> /dev/null; then
        echo -e "${C_YELLOW}⚠ This example requires Termux:API${C_RESET}"
        echo "Install with: pkg install termux-api"
        pause
        return
    fi

    echo -e "${C_GREEN}Output:${C_RESET}"
    echo "════════════════════════════════════════════════════════"

    cd "$SCRIPT_DIR"
    eval "$command" || echo -e "\n${C_YELLOW}⚠ Command failed - check your configuration${C_RESET}"

    echo "════════════════════════════════════════════════════════"
    pause
}

# --- Check Configuration ---
check_config() {
    if [ ! -f "$CONFIG_DIR/env" ]; then
        echo -e "${C_YELLOW}⚠ No configuration found${C_RESET}"
        echo ""
        echo "Please run the setup wizard first:"
        echo "  bash setup.sh"
        echo ""
        read -p "Press ENTER to exit..."
        exit 1
    fi

    source "$CONFIG_DIR/env"

    if [[ -z "${OPENAI_API_KEY:-}" ]] && [[ -z "${GEMINI_API_KEY:-}" ]]; then
        echo -e "${C_YELLOW}⚠ No API key configured${C_RESET}"
        echo ""
        echo "Please run the setup wizard to configure your API key:"
        echo "  bash setup.sh"
        echo ""
        read -p "Press ENTER to exit..."
        exit 1
    fi
}

# --- Example Categories ---

example_basics() {
    print_header
    echo -e "${C_BOLD}Basic Examples${C_RESET}"
    echo ""

    local choice
    while true; do
        print_menu_item "1" "Simple Question"
        print_menu_item "2" "Code Explanation"
        print_menu_item "3" "Translation"
        print_menu_item "4" "Creative Writing"
        print_menu_item "0" "Back to Main Menu"
        echo ""
        read -p "Choose an example [0-4]: " choice

        case "$choice" in
            1)
                run_example \
                    "Simple Question" \
                    "Ask the AI a straightforward question" \
                    'bash ai_cli.sh -p "What are the three laws of robotics?" --no-save'
                ;;
            2)
                run_example \
                    "Code Explanation" \
                    "Get the AI to explain programming concepts" \
                    'bash ai_cli.sh -p "Explain what a REST API is and how it works" --no-save'
                ;;
            3)
                run_example \
                    "Translation" \
                    "Translate text to another language" \
                    'bash ai_cli.sh -p "Translate to Spanish: I love programming with AI tools" --no-save'
                ;;
            4)
                run_example \
                    "Creative Writing" \
                    "Generate creative content" \
                    'bash ai_cli.sh -p "Write a haiku about artificial intelligence" --no-save'
                ;;
            0) return ;;
            *) echo "Please enter 0-4" ;;
        esac

        print_header
        echo -e "${C_BOLD}Basic Examples${C_RESET}"
        echo ""
    done
}

example_advanced() {
    print_header
    echo -e "${C_BOLD}Advanced Examples${C_RESET}"
    echo ""

    local choice
    while true; do
        print_menu_item "1" "Custom System Prompt"
        print_menu_item "2" "Code Review"
        print_menu_item "3" "Data Analysis"
        print_menu_item "4" "Debugging Helper"
        print_menu_item "0" "Back to Main Menu"
        echo ""
        read -p "Choose an example [0-4]: " choice

        case "$choice" in
            1)
                run_example \
                    "Custom System Prompt" \
                    "Use a system prompt to set AI behavior" \
                    'bash ai_cli.sh -s "You are a pirate captain" -p "Tell me about treasure" --no-save'
                ;;
            2)
                run_example \
                    "Code Review" \
                    "Ask AI to review code quality" \
                    'bash ai_cli.sh -s "You are an expert code reviewer" -p "Review this: for i in range(10): print i" --no-save'
                ;;
            3)
                run_example \
                    "Data Analysis" \
                    "Analyze data and provide insights" \
                    'bash ai_cli.sh -p "Analyze this data and find trends: Sales Q1: 100, Q2: 150, Q3: 120, Q4: 200" --no-save'
                ;;
            4)
                run_example \
                    "Debugging Helper" \
                    "Get help debugging code issues" \
                    'bash ai_cli.sh -p "Why does this fail? let x = 5; console.log(y);" --no-save'
                ;;
            0) return ;;
            *) echo "Please enter 0-4" ;;
        esac

        print_header
        echo -e "${C_BOLD}Advanced Examples${C_RESET}"
        echo ""
    done
}

example_tools() {
    print_header
    echo -e "${C_BOLD}Specialized Tools${C_RESET}"
    echo ""

    local choice
    while true; do
        print_menu_item "1" "Summarize URL"
        print_menu_item "2" "Summarize File"
        print_menu_item "3" "Summarize Clipboard (Termux:API)"
        print_menu_item "4" "Save Output to File"
        print_menu_item "0" "Back to Main Menu"
        echo ""
        read -p "Choose an example [0-4]: " choice

        case "$choice" in
            1)
                run_example \
                    "URL Summarizer" \
                    "Fetch and summarize web content" \
                    'bash url_summarize.sh -u "https://en.wikipedia.org/wiki/Termux" --no-save'
                ;;
            2)
                echo ""
                echo "This will summarize this README file..."
                run_example \
                    "File Summarizer" \
                    "Summarize the contents of a local file" \
                    'bash file_summarize.sh -f README.md --no-save'
                ;;
            3)
                echo ""
                echo "Copy some text to your clipboard first, then press ENTER"
                pause
                run_example \
                    "Clipboard Summarizer" \
                    "Summarize text from your clipboard" \
                    'bash clip_summarize.sh --no-save'
                ;;
            4)
                echo ""
                echo "This will save the output to: ~/.local/share/termux-ai/out/"
                run_example \
                    "Save Output" \
                    "Save AI responses to a file" \
                    'DRY_RUN=0 bash ai_cli.sh -p "Generate 5 creative project ideas"'
                ;;
            0) return ;;
            *) echo "Please enter 0-4" ;;
        esac

        print_header
        echo -e "${C_BOLD}Specialized Tools${C_RESET}"
        echo ""
    done
}

example_practical() {
    print_header
    echo -e "${C_BOLD}Practical Use Cases${C_RESET}"
    echo ""

    local choice
    while true; do
        print_menu_item "1" "Git Commit Messages"
        print_menu_item "2" "Email Drafting"
        print_menu_item "3" "Learning Helper"
        print_menu_item "4" "Brainstorming Ideas"
        print_menu_item "0" "Back to Main Menu"
        echo ""
        read -p "Choose an example [0-4]: " choice

        case "$choice" in
            1)
                run_example \
                    "Git Commit Message Generator" \
                    "Generate professional commit messages" \
                    'bash ai_cli.sh -p "Write a git commit message for: Added user authentication with JWT tokens" --no-save'
                ;;
            2)
                run_example \
                    "Email Drafting" \
                    "Draft professional emails" \
                    'bash ai_cli.sh -p "Draft a professional email requesting a meeting to discuss a project proposal" --no-save'
                ;;
            3)
                run_example \
                    "Learning Helper" \
                    "Get explanations for complex topics" \
                    'bash ai_cli.sh -p "Explain Docker containers in simple terms with an analogy" --no-save'
                ;;
            4)
                run_example \
                    "Brainstorming Ideas" \
                    "Generate creative ideas for projects" \
                    'bash ai_cli.sh -p "Give me 5 innovative mobile app ideas for productivity" --no-save'
                ;;
            0) return ;;
            *) echo "Please enter 0-4" ;;
        esac

        print_header
        echo -e "${C_BOLD}Practical Use Cases${C_RESET}"
        echo ""
    done
}

show_tips() {
    print_header
    echo -e "${C_BOLD}Tips & Tricks${C_RESET}"
    echo ""

    cat << EOF
${C_GREEN}▶ Saving Outputs${C_RESET}
  By default, outputs are NOT saved (dry-run mode).
  To save responses:
    DRY_RUN=0 bash ai_cli.sh -p "your prompt"

${C_GREEN}▶ Reading from Files${C_RESET}
  You can use files as prompts:
    bash ai_cli.sh -f myfile.txt

${C_GREEN}▶ Piping Input${C_RESET}
  Pipe data directly to the AI:
    echo "Your text" | bash ai_cli.sh -p -
    cat file.txt | bash ai_cli.sh -p -

${C_GREEN}▶ Choosing Models${C_RESET}
  Use specific AI models:
    bash ai_cli.sh -m gpt-4o -p "your prompt"
    bash ai_cli.sh -m gemini-1.5-pro-latest -p "your prompt"

${C_GREEN}▶ System Prompts${C_RESET}
  Set the AI's behavior/role:
    bash ai_cli.sh -s "You are a helpful teacher" -p "Explain photosynthesis"

${C_GREEN}▶ Configuration${C_RESET}
  Edit your settings:
    nano ~/.config/termux-ai/env

${C_GREEN}▶ View Saved Outputs${C_RESET}
  Saved responses are stored at:
    ~/.local/share/termux-ai/out/

${C_GREEN}▶ Check Your Setup${C_RESET}
  Verify everything is working:
    bash 00_check_env.sh

${C_GREEN}▶ Environment Variables${C_RESET}
  Useful overrides:
    DRY_RUN=0          # Enable file saving
    AI_TIMEOUT=120     # Increase timeout to 2 minutes
    PROVIDER=gemini    # Force specific provider

EOF
    pause
}

# --- Main Menu ---
main_menu() {
    while true; do
        print_header
        echo "Welcome to the interactive quick-start guide!"
        echo ""
        echo "Choose a category to explore:"
        echo ""

        print_menu_item "1" "Basic Examples (Questions, Translations, etc.)"
        print_menu_item "2" "Advanced Examples (Custom prompts, Code review)"
        print_menu_item "3" "Specialized Tools (URL/File/Clipboard)"
        print_menu_item "4" "Practical Use Cases (Emails, Learning, etc.)"
        print_menu_item "5" "Tips & Tricks"
        print_menu_item "6" "Run Setup Wizard"
        print_menu_item "0" "Exit"

        echo ""
        read -p "Enter your choice [0-6]: " choice

        case "$choice" in
            1) example_basics ;;
            2) example_advanced ;;
            3) example_tools ;;
            4) example_practical ;;
            5) show_tips ;;
            6)
                clear
                bash "$SCRIPT_DIR/setup.sh"
                ;;
            0)
                clear
                echo "Thanks for using Termux AI Toolkit!"
                echo "For more information, see README.md"
                exit 0
                ;;
            *)
                echo "Please enter 0-6"
                sleep 1
                ;;
        esac
    done
}

# --- Main ---
main() {
    check_config
    main_menu
}

main "$@"
