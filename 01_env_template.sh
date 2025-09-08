#!/data/data/com.termux/files/usr/bin/bash
#
# Termux AI Toolkit - Environment Configuration Template
#
# --- HOW TO USE ---
# 1. Copy this file to a new file named 'env' in the config directory:
#    mkdir -p ~/.config/termux-ai
#    cp 01_env_template.sh ~/.config/termux-ai/env
#
# 2. Edit the new '~/.config/termux-ai/env' file with your text editor (e.g., nano).
#
# 3. Add your secret API key(s) below.
#
# 4. In your terminal, run `source ~/.config/termux-ai/env` to load these variables.
#    You must do this for every new Termux session where you want to use the scripts.
#
# --- IMPORTANT: KEEP THIS FILE PRIVATE. DO NOT SHARE IT. ---

# --- AI Provider and API Keys ---
# The scripts will automatically use the provider for the key you set.
# If both keys are set, OpenAI will be used by default.
# You can force a provider by uncommenting the line below:
# export PROVIDER="gemini" # or "openai"

# --- Add your secret API keys here ---
# Uncomment the line for the service you want to use and paste your key.

# For OpenAI (Models: gpt-4o, gpt-4o-mini, gpt-4-turbo)
# export OPENAI_API_KEY="sk-..."

# For Google Gemini (Models: gemini-1.5-pro-latest, gemini-1.5-flash-latest)
# export GEMINI_API_KEY="..."


# --- Model Selection ---
# Set the default models to use for each provider.
# You can override these with the `-m` flag in ai_cli.sh.

export MODEL_OPENAI="gpt-4o-mini"
export MODEL_GEMINI="gemini-1.5-flash-latest"


# --- Advanced Settings (Optional) ---

# Default behavior is a "dry run" (read-only).
# To allow scripts to write output files, uncomment the line below.
# You can also set this per-command, e.g., `DRY_RUN=0 ./clip_summarize.sh`
# export DRY_RUN=0

# Timeout in seconds for API calls.
export AI_TIMEOUT=60

# --- End of Configuration ---
#
# After editing, save the file and run:
# source ~/.config/termux-ai/env
#
# Then check your setup with:
# ./00_check_env.sh
#
