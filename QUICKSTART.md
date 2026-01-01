# Quick Start Guide

Get started with the Termux AI Toolkit in 5 minutes or less!

## Choose Your Path

### 🤖 For Termux/Android Users

**Goal**: Use AI from your Android device's command line

1. **Install Termux** from [F-Droid](https://f-droid.org/en/packages/com.termux/)

2. **Run the installer**:
   ```bash
   curl -sL https://raw.githubusercontent.com/warrenet/termux-ai-toolkit/main/install_toolkit.sh | bash
   cd ~/termux-ai-toolkit
   ```

3. **Install dependencies**:
   ```bash
   pkg install curl jq
   ```

4. **Set up your API key**:
   ```bash
   mkdir -p ~/.config/termux-ai
   cp 01_env_template.sh ~/.config/termux-ai/env
   nano ~/.config/termux-ai/env
   ```
   Uncomment and add your API key (get one from [OpenAI](https://platform.openai.com/api-keys) or [Google AI](https://ai.google.dev/))

5. **Load configuration and test**:
   ```bash
   source ~/.config/termux-ai/env
   bash 00_check_env.sh
   # Or use the unified launcher:
   bash termux-ai check
   bash termux-ai ask -p "Hello, AI!"
   ```

✅ **You're ready!** Try these next:
- `bash termux-ai clip` - Summarize clipboard
- `bash termux-ai url -u "https://example.com"` - Summarize a webpage
- `bash termux-ai ask --help` - See all options
- See [optional_widget_setup.md](optional_widget_setup.md) for home screen widgets

---

### 🎨 For Web Users (Agent Builder)

**Goal**: Visually design AI agent prompts in your browser

1. **Clone or download this repository**:
   ```bash
   git clone https://github.com/warrenet/termux-ai-toolkit.git
   cd termux-ai-toolkit
   ```

2. **Open the Agent Builder**:
   - Simply open `index.html` in any modern web browser
   - Or use a local server:
     ```bash
     python -m http.server 8000
     # Then visit http://localhost:8000
     ```

3. **Start building**:
   - Drag blocks from the toolbox to the canvas
   - Click blocks to edit their content
   - Click "Generate" to see your complete prompt
   - Click "Save" to store your configuration

✅ **You're ready!** The Agent Builder works offline by default.

**Optional**: Set up Firebase for cloud storage (see README.md)

---

## Common Issues

### "Command not found: jq"
```bash
pkg install jq
```

### "No API keys found"
1. Make sure you created `~/.config/termux-ai/env`
2. Run `source ~/.config/termux-ai/env` in your current session
3. Verify your API key is valid

### "DRY_RUN is preventing file writes"
This is by design for safety! To save outputs:
```bash
DRY_RUN=0 bash ai_cli.sh -p "Your prompt"
```

---

## What's Next?

- 📖 Read the [full README](README.md) for all features
- 📚 Check [README_first.md](README_first.md) for detailed usage
- 🤝 See [CONTRIBUTING.md](CONTRIBUTING.md) to contribute
- 🐛 Report issues on [GitHub](https://github.com/warrenet/termux-ai-toolkit/issues)

**Happy AI-ing!** 🚀
