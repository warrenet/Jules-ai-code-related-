# Termux AI Toolkit

A collection of safe, simple, and powerful Bash scripts to bring AI capabilities to your Android device via Termux.

This toolkit is built on a "safety first" principle. Scripts are non-destructive, make no changes to your system outside of a dedicated workspace, and are designed to work immediately with a simple copy and paste.

---

## 🛑 Safety First! Your Guarantees

Before you begin, understand these core safety rules:

*   **Non-Destructive by Default:** Scripts run in a **read-only** mode (`DRY_RUN=1`) by default. They will not write any files to your device until you explicitly allow them to by setting `DRY_RUN=0`.
*   **Isolated Workspace:** All files created by this toolkit (outputs, configs, logs) are stored exclusively within the `~/.config/termux-ai`, `~/.local/share/termux-ai`, and `~/.cache/termux-ai` directories. **No other locations are ever touched.**
*   **No Automatic System Changes:** The scripts will **never** automatically install packages, modify your `.bashrc` or `PATH`, or grant permissions. If a dependency is missing (like `jq`), the script will exit with a helpful message showing the exact command you can run to install it yourself.
*   **You Are In Control:** You are encouraged to read the scripts. They are heavily commented and designed for clarity.

---

## 🚀 90-Second Quickstart

Get your first AI-powered result in under two minutes.

### Step 1: Get the Scripts

The easiest way is to use the installer script below. It will create a single directory `~/termux-ai-toolkit` and place all the necessary files inside.

Just copy the entire block below and paste it into your Termux terminal.

```bash
# This installer script is a safe and easy way to get all toolkit files.
# It will be generated in the final step of this process.
# For now, imagine a self-contained script here that creates
# all the other files in a `~/termux-ai-toolkit` directory.
echo "Installer script will be placed here."
```

### Step 2: Set Your API Key

The toolkit needs an API key for either OpenAI (ChatGPT) or Google (Gemini).

1.  **Create a config file:**
    ```bash
    # First, create the config directory
    mkdir -p ~/.config/termux-ai

    # Then, copy the template. (Assuming you ran the installer and are in ~/termux-ai-toolkit)
    cp 01_env_template.sh ~/.config/termux-ai/env
    ```

2.  **Edit the `env` file:**
    Open the file in a text editor (like `nano` or `vim`) and add your key.
    ```bash
    nano ~/.config/termux-ai/env
    ```
    Uncomment the appropriate line and paste your key. **Never share this file or your key.**

    ```sh
    # --- CHOOSE YOUR PROVIDER ---
    # The script will auto-detect which key you have set.
    # If both are set, OpenAI is preferred by default.
    # You can force a provider by uncommenting this line:
    # PROVIDER="gemini" # or "openai"

    # --- SET YOUR API KEYS ---
    # Add your secret API keys here.
    # For OpenAI (ChatGPT):
    OPENAI_API_KEY="sk-..."

    # For Google (Gemini):
    # GEMINI_API_KEY="..."
    ```

3.  **Load the environment:**
    For the keys to be active in your current session, `source` the file:
    ```bash
    source ~/.config/termux-ai/env
    ```
    *(You will need to do this for every new Termux session.)*

### Step 3: Check Your Environment

Run the diagnostic script to make sure everything is ready.
```bash
# (Assuming you are in ~/termux-ai-toolkit)
bash 00_check_env.sh
```
If anything is missing, it will tell you exactly how to fix it.

### Step 4: Your First AI Command!

You're ready! Use the main `ai_cli.sh` script to ask a question.
```bash
# Use a pipe to send a question
echo "What are the key features of the Bash shell?" | bash ai_cli.sh -p -

# Or use the -p flag directly
bash ai_cli.sh -p "Suggest three names for a new tech blog."
```

You should see an AI-generated response directly in your terminal! Because `DRY_RUN` is on by default, no files were saved. To save your first response, try:
```bash
DRY_RUN=0 bash ai_cli.sh -p "Hello, world!"
```
This will create a timestamped output file in `~/.local/share/termux-ai/out/`.

---

## 📖 Script Usage & Examples

All scripts are located in the `~/termux-ai-toolkit` directory.

### `ai_cli.sh`
The core engine. Sends prompts to the AI.

*   **Example 1: Ask a simple question**
    ```bash
    bash ai_cli.sh -p "Explain the concept of 'idempotence' in scripting."
    ```
*   **Example 2: Read prompt from a file**
    ```bash
    echo "Summarize this text for me." > my_prompt.txt
    bash ai_cli.sh -f my_prompt.txt
    ```

### `clip_summarize.sh`
Summarizes the current content of your clipboard. Requires the Termux:API app.

*   **Example 1: Summarize copied text**
    *(First, copy some text from any app on your phone)*
    ```bash
    bash clip_summarize.sh
    ```
*   **Example 2: Save the summary to a file**
    ```bash
    DRY_RUN=0 bash clip_summarize.sh
    ```

### `url_summarize.sh`
Fetches the content of a URL and summarizes it.

*   **Example 1: Summarize a news article (in read-only mode)**
    ```bash
    bash url_summarize.sh -u "https://www.bbc.com/news/technology"
    ```
*   **Example 2: Summarize a blog post and save the output**
    ```bash
    DRY_RUN=0 bash url_summarize.sh -u "https://example.com/some-article"
    ```

### `file_summarize.sh`
Summarizes a local text file on your device.

*   **Example 1: Summarize a script you downloaded**
    ```bash
    # First, give Termux storage access if you haven't already
    # termux-setup-storage
    bash file_summarize.sh -f '~/storage/downloads/some_text_file.txt'
    ```
*   **Example 2: Summarize a project README**
    ```bash
    bash file_summarize.sh -f '~/termux-ai-toolkit/README_first.md'
    ```

---

## 📚 Glossary

*   **`DRY_RUN`**: An environment variable that controls whether scripts can write files. `DRY_RUN=1` (the default) is read-only. `DRY_RUN=0` allows writing to the workspace.
*   **Termux:API**: A separate Android app that you can install from F-Droid. It provides command-line access to Android features like the clipboard (`termux-clipboard-get`) and notifications (`termux-notification`). Our scripts use these features if available.
*   **Termux:Widget**: A separate app that lets you run scripts directly from your home screen. See `optional_widget_setup.md` for instructions.

---

## 🔧 Troubleshooting

*   **`command not found: jq`**: You need to install the `jq` package, which is essential for processing AI responses. Run: `pkg install jq`
*   **`command not found: termux-clipboard-get`**: The `clip_summarize.sh` script requires the Termux:API app and package. Install the app from F-Droid, then run: `pkg install termux-api`
*   **API Errors (401 Unauthorized)**: This almost always means your API key is incorrect or not loaded in your shell.
    1.  Double-check the key in `~/.config/termux-ai/env`.
    2.  Make sure you've run `source ~/.config/termux-ai/env` in your *current* terminal session.
    3.  Verify the key has credit or is active on the provider's website (OpenAI/Google AI).
