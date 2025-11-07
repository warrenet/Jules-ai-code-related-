# Termux AI Toolkit

> Bring powerful AI capabilities to your Android device with simple, safe, and privacy-focused Bash scripts.

**⚡ New here?** Check out the [Quick Start Guide](QUICKSTART.md) to get up and running in 5 minutes!

---

A collection of carefully crafted scripts that enable you to use OpenAI GPT and Google Gemini models directly from your Android device via Termux. No complicated setup, no hidden behaviors - just straightforward AI tools at your fingertips.

## 📦 What's Included

This repository contains **two main components**:

### 1. 🤖 Termux AI Command-Line Tools
A suite of Bash scripts for Android/Termux that bring AI capabilities to your mobile device:
- **`termux-ai`** - Unified launcher for easy access to all commands
- **`ai_cli.sh`** - Universal AI command-line interface
- **`clip_summarize.sh`** - Summarize clipboard content
- **`url_summarize.sh`** - Fetch and summarize web pages
- **`file_summarize.sh`** - Analyze local text files
- **`00_check_env.sh`** - Environment diagnostic tool
- **`install_toolkit.sh`** - One-command installer

### 2. 🎨 Agent Builder Web Application
A browser-based visual tool for creating AI agent prompts:
- **`index.html`** + **`script.js`** - Interactive drag-and-drop agent builder
- Design complex AI agent workflows visually
- Export and share agent configurations
- Firebase integration for cloud storage

Choose the tool that fits your needs, or use both together!

---

## Features

- **Multiple AI Providers**: Support for OpenAI (GPT-4o, GPT-4o-mini) and Google Gemini (1.5 Pro/Flash)
- **Privacy-First Design**: Scripts run locally on your device, you control all data
- **Safety by Default**: Non-destructive dry-run mode prevents accidental writes
- **Zero Dependencies Bloat**: Uses only standard Termux tools (curl, jq)
- **Streaming Responses**: Real-time AI output for better user experience
- **Smart Summarization**: Built-in map-reduce for large documents
- **Android Integration**: Optional widgets and clipboard support via Termux:API

## Quick Start

### Prerequisites

You'll need:
- Android device with [Termux](https://f-droid.org/en/packages/com.termux/) installed from F-Droid
- An API key from [OpenAI](https://platform.openai.com/api-keys) or [Google AI](https://ai.google.dev/)

### Installation

#### Option 1: One-Line Install (Recommended)

Run this command in Termux to download and execute the installer:

```bash
curl -sL https://raw.githubusercontent.com/warrenet/Jules-ai-code-related-/main/install_toolkit.sh | bash
```

#### Option 2: Clone from GitHub

```bash
# Clone the repository
git clone https://github.com/warrenet/Jules-ai-code-related-.git ~/termux-ai-toolkit

# Navigate to the directory
cd ~/termux-ai-toolkit

# Make scripts executable
chmod +x *.sh
```

### Configuration

1. Install required dependencies:
   ```bash
   pkg install curl jq
   ```

2. Create your configuration file:
   ```bash
   mkdir -p ~/.config/termux-ai
   cp 01_env_template.sh ~/.config/termux-ai/env
   ```

3. Edit the config file and add your API key:
   ```bash
   nano ~/.config/termux-ai/env
   ```

   Uncomment and set your API key:
   ```bash
   export OPENAI_API_KEY="sk-..."
   # OR
   export GEMINI_API_KEY="..."
   ```

4. Load the configuration:
   ```bash
   source ~/.config/termux-ai/env
   ```

5. Verify everything is ready:
   ```bash
   bash 00_check_env.sh
   # Or use the unified launcher:
   bash termux-ai check
   ```

### First Command

```bash
# Using the unified launcher (recommended):
bash termux-ai ask -p "Explain quantum computing in simple terms"

# Or call scripts directly:
bash ai_cli.sh -p "Explain quantum computing in simple terms"

# Save output to a file (disable dry-run)
DRY_RUN=0 bash termux-ai ask -p "Write a haiku about coding"
```

## Usage Examples

### Using the Unified Launcher (Recommended)

The `termux-ai` launcher provides a simple, unified interface to all toolkit commands:

```bash
# Check your environment
bash termux-ai check

# Ask the AI a question
bash termux-ai ask -p "What is Bash?"

# Summarize clipboard content
bash termux-ai clip

# Summarize a web page
bash termux-ai url -u "https://example.com/article"

# Summarize a local file
bash termux-ai file -f ~/document.txt

# Run tests
bash termux-ai test

# Get help
bash termux-ai --help
bash termux-ai ask --help
```

### Core AI CLI (`ai_cli.sh`)

The main interface for interacting with AI models:

```bash
# Simple prompt
bash ai_cli.sh -p "What is the capital of France?"

# Read from stdin
echo "Translate this to Spanish: Hello, world!" | bash ai_cli.sh -p -

# Use a specific model
bash ai_cli.sh -p "Explain recursion" -m gpt-4o

# Force a specific provider
bash ai_cli.sh -p "Tell me a joke" --provider gemini

# Custom system prompt
bash ai_cli.sh -p "Review this code" -s "You are an expert code reviewer"
```

### Clipboard Summarizer (`clip_summarize.sh`)

Requires [Termux:API](https://f-droid.org/en/packages/com.termux.api/):

```bash
# Install Termux:API support
pkg install termux-api

# Copy some text in any app, then:
bash clip_summarize.sh

# Save the summary
DRY_RUN=0 bash clip_summarize.sh
```

### URL Summarizer (`url_summarize.sh`)

Fetch and summarize web content:

```bash
# Summarize a news article
bash url_summarize.sh -u "https://example.com/article"

# Large articles are automatically chunked and map-reduced
DRY_RUN=0 bash url_summarize.sh -u "https://en.wikipedia.org/wiki/Artificial_intelligence"
```

### File Summarizer (`file_summarize.sh`)

Analyze local text files:

```bash
# Summarize a document
bash file_summarize.sh -f ~/storage/downloads/report.txt

# Summarize code
bash file_summarize.sh -f ~/myproject/main.py
```

## Advanced Features

### Environment Variables

Control script behavior with environment variables:

- `DRY_RUN`: Set to `0` to allow file writes (default: `1`)
- `AI_TIMEOUT`: API request timeout in seconds (default: `60`)
- `PROVIDER`: Force provider - `openai` or `gemini`
- `MODEL_OPENAI`: Default OpenAI model (default: `gpt-4o-mini`)
- `MODEL_GEMINI`: Default Gemini model (default: `gemini-1.5-flash-latest`)

### Home Screen Widgets

Create 1-tap AI shortcuts on your home screen using Termux:Widget. See [optional_widget_setup.md](optional_widget_setup.md) for detailed instructions.

### Cost Management

The toolkit includes automatic warnings for large inputs:

```bash
# For inputs >8000 tokens, you'll be prompted to confirm
bash ai_cli.sh -f very_large_file.txt
```

## Architecture

### File Structure

```
termux-ai-toolkit/
├── 00_check_env.sh        # Environment diagnostic tool
├── 01_env_template.sh     # Configuration template
├── ai_cli.sh              # Core AI interface
├── clip_summarize.sh      # Clipboard summarization
├── url_summarize.sh       # URL content summarization
├── file_summarize.sh      # File summarization
├── install_toolkit.sh     # Self-contained installer
├── tests.sh               # Test suite
├── README.md              # This file
├── README_first.md        # Detailed user guide
└── optional_widget_setup.md  # Widget configuration guide
```

### Data Storage

All toolkit data is stored in isolated directories:

- `~/.config/termux-ai/env` - Your API keys and settings
- `~/.local/share/termux-ai/out/` - Saved AI responses
- `~/.cache/termux-ai/run.log` - Execution logs

## Security & Privacy

### Safety Guarantees

1. **Isolated Workspace**: Scripts only write to dedicated toolkit directories
2. **No Auto-Install**: Never automatically installs packages or modifies system
3. **API Key Protection**: Keys masked in all logs
4. **Dry-Run Default**: Must explicitly enable file writing
5. **No Telemetry**: Zero tracking or analytics

### API Key Security

- Never commit your `~/.config/termux-ai/env` file
- API keys are sent only to official provider endpoints
- Consider using API key rotation and spending limits

## Troubleshooting

### Common Issues

**`command not found: jq`**
```bash
pkg install jq
```

**`command not found: termux-clipboard-get`**
```bash
# Install Termux:API app from F-Droid first
pkg install termux-api
```

**API Errors (401 Unauthorized)**
1. Check your API key in `~/.config/termux-ai/env`
2. Run `source ~/.config/termux-ai/env` in your current session
3. Verify the key is active on the provider's website

**Slow responses**
- Try using faster models: `gpt-4o-mini` or `gemini-1.5-flash-latest`
- Check your internet connection
- Reduce input size

### Getting Help

- Check the [detailed user guide](README_first.md)
- Review the [widget setup guide](optional_widget_setup.md)
- Run the diagnostic: `bash 00_check_env.sh`
- Open an issue on GitHub

## Agent Builder Web Application

### Overview

The Agent Builder is a visual, browser-based tool for designing AI agent prompts and workflows. It provides a drag-and-drop interface for creating complex agent configurations.

### Features

- **Visual Workflow Designer**: Drag and drop blocks to create agent prompts
- **Multiple Block Types**: 
  - System prompts
  - User messages
  - Context blocks
  - Tools and capabilities
- **Real-time Preview**: See your agent prompt as you build
- **Cloud Storage**: Save and load configurations via Firebase
- **Export/Import**: Share agent designs with others
- **Mobile Responsive**: Works on desktop and mobile browsers

### Quick Start

1. **Open the Application**:
   - Simply open `index.html` in any modern web browser
   - Or deploy to a web server for remote access

2. **Build Your Agent**:
   - Click on blocks in the toolbox to add them to the canvas
   - Drag blocks to reorder them
   - Click on any block to edit its content
   - Use the "Generate" button to see the complete prompt

3. **Save and Share**:
   - Click "Save" to store your agent configuration
   - Click "Load" to retrieve saved configurations
   - Copy the generated prompt to use with any AI service

### Firebase Configuration (Optional)

To enable cloud storage features:

1. Create a Firebase project at [firebase.google.com](https://firebase.google.com)
2. Enable Firestore and Authentication
3. Update the Firebase configuration in `index.html`:
   ```javascript
   const __firebase_config = `{
     "apiKey": "your-api-key",
     "authDomain": "your-project.firebaseapp.com",
     "projectId": "your-project-id"
   }`;
   ```

### Local Usage

The Agent Builder works offline by default with local storage. No Firebase setup is required for basic functionality.

## Development

### Repository Structure

For a detailed explanation of the codebase architecture, design decisions, and how to extend the toolkit, see [ARCHITECTURE.md](ARCHITECTURE.md).

### Running Tests

```bash
bash tests.sh
# Or use the launcher:
bash termux-ai test
```

### Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Add tests for new features
4. Ensure all tests pass
5. Submit a pull request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## Roadmap

- [ ] Support for Anthropic Claude
- [ ] Conversation history and context management
- [ ] Voice input via Termux:API
- [ ] Image description support
- [ ] Code execution sandbox
- [ ] Multi-language support

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built for the [Termux](https://termux.dev/) community
- Inspired by the Unix philosophy: Do one thing well
- Thanks to all contributors and testers

---

**Made with care for the Android power user community**

Star this repo if you find it useful!
