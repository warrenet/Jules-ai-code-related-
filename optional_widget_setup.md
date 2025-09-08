# Optional: Termux:Widget Setup

This guide will help you create 1-tap shortcuts for the AI Toolkit on your Android home screen using the Termux:Widget app.

## Prerequisites

1.  You have installed the main **Termux AI Toolkit** in the `~/termux-ai-toolkit` directory.
2.  You have installed the **Termux:Widget** app from F-Droid or the Google Play Store.
3.  You have installed the **Termux:API** app and run `pkg install termux-api`. The widgets use `termux-dialog`, `termux-toast`, and `termux-clipboard-get`.
4.  You have configured your API keys in `~/.config/termux-ai/env`.

## How It Works

Termux:Widget runs scripts that you place in the `~/.shortcuts/` directory. We will create a few simple scripts there that call our main toolkit scripts.

Simply copy and paste the command blocks below into your main Termux session to create the shortcut files.

---

### Widget 1: Quick AI Ask

This widget will pop up a dialog box asking for a prompt. The AI's response will be shown as a temporary "toast" notification on your screen and saved to a file.

**➡️ Create the shortcut file:**
Copy and paste this entire block into Termux and press Enter.

```bash
mkdir -p ~/.shortcuts
cat <<'EOF' > ~/.shortcuts/01-ai-ask
#!/data/data/com.termux/files/usr/bin/bash
# Shortcut for a quick AI prompt.

# Source environment to get API keys
[ -f "$HOME/.config/termux-ai/env" ] && source "$HOME/.config/termux-ai/env"

TOOLKIT_DIR="$HOME/termux-ai-toolkit"

# Get input from a user dialog
prompt_input=$(termux-dialog -t "Ask AI" | jq -r .text)

# If user entered text, run the command
if [ -n "$prompt_input" ]; then
    # Ensure DRY_RUN=0 to save the output
    export DRY_RUN=0

    # Run the command and show the full response in a toast
    # Note: Toasts have a text limit; this shows the beginning of the answer.
    summary=$(cd "$TOOLKIT_DIR" && bash ai_cli.sh -p "$prompt_input")
    termux-toast -g middle -b black -c white "$summary"
fi
EOF
chmod +x ~/.shortcuts/01-ai-ask
```

---

### Widget 2: Summarize Clipboard

This widget will instantly summarize any text you have copied to your clipboard. The summary will appear as a toast notification and be saved to a file.

**➡️ Create the shortcut file:**
Copy and paste this entire block into Termux and press Enter.

```bash
mkdir -p ~/.shortcuts
cat <<'EOF' > ~/.shortcuts/02-summarize-clipboard
#!/data/data/com.termux/files/usr/bin/bash
# Shortcut to summarize clipboard content.

# Source environment to get API keys
[ -f "$HOME/.config/termux-ai/env" ] && source "$HOME/.config/termux-ai/env"

TOOLKIT_DIR="$HOME/termux-ai-toolkit"

# Ensure DRY_RUN=0 to save the output
export DRY_RUN=0

# Run the script and show the result in a toast
summary=$(cd "$TOOLKIT_DIR" && bash clip_summarize.sh)
termux-toast -g middle -b black -c white "$summary"
EOF
chmod +x ~/.shortcuts/02-summarize-clipboard
```

---

### Widget 3: Summarize Last URL

This widget will grab the most recent URL from your clipboard and summarize it.

**➡️ Create the shortcut file:**
Copy and paste this entire block into Termux and press Enter.

```bash
mkdir -p ~/.shortcuts
cat <<'EOF' > ~/.shortcuts/03-summarize-url
#!/data/data/com.termux/files/usr/bin/bash
# Shortcut to summarize the last URL in the clipboard.

# Source environment to get API keys
[ -f "$HOME/.config/termux-ai/env" ] && source "$HOME/.config/termux-ai/env"

TOOLKIT_DIR="$HOME/termux-ai-toolkit"

# Get URL from clipboard
url=$(termux-clipboard-get)

# Basic check if it's a URL
if [[ "$url" != http* ]]; then
    termux-toast -g middle -b black -c white "No URL found in clipboard."
    exit 1
fi

# Ensure DRY_RUN=0 to save the output
export DRY_RUN=0

# Notify user that we are starting
termux-toast -g middle "Summarizing URL: $url"

# Run the command and show the result in a new toast
summary=$(cd "$TOOLKIT_DIR" && bash url_summarize.sh -u "$url")
termux-toast -g middle -b black -c white "$summary"
EOF
chmod +x ~/.shortcuts/03-summarize-url
```

---

## Final Step: Add the Widget

1.  Go to your phone's **Home Screen**.
2.  **Long-press** on an empty space and choose **"Widgets"**.
3.  Find the **Termux:Widget** and drag it to your home screen.
4.  A list of your shortcut scripts (`01-ai-ask`, etc.) will appear. Select one.
5.  Repeat for the other scripts.

You can now tap these icons to run the AI commands directly from your home screen!
