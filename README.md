# Termux AI Toolkit

> Bring powerful AI capabilities to your Android device with simple, safe, and privacy-focused Bash scripts.

A collection of carefully crafted scripts that enable you to use OpenAI GPT and Google Gemini models directly from your Android device via Termux. No complicated setup, no hidden behaviors - just straightforward AI tools at your fingertips.

## Features

- **Multiple AI Providers**: Support for OpenAI (GPT-4o, GPT-4o-mini) and Google Gemini (1.5 Pro/Flash)
- **Privacy-First Design**: Scripts run locally on your device, you control all data
- **Safety by Default**: Non-destructive dry-run mode prevents accidental writes
- **Zero Dependencies Bloat**: Uses only standard Termux tools (curl, jq)
- **Streaming Responses**: Real-time AI output for better user experience
- **Smart Summarization**: Built-in map-reduce for large documents
- **Android Integration**: Optional widgets and clipboard support via Termux:API

## Quick Start

### 🚀 Fastest Way to Get Started (2 minutes)

**Step 1:** Clone and enter the directory
```bash
git clone https://github.com/warrenet/Jules-ai-code-related-.git ~/termux-ai-toolkit
cd ~/termux-ai-toolkit
```

**Step 2:** Run the setup wizard
```bash
bash setup.sh
```

The wizard will:
- ✅ Install dependencies automatically (curl, jq)
- ✅ Guide you through API key configuration
- ✅ Test your setup
- ✅ Run a live demo

**Step 3:** Start using AI!
```bash
bash ai_cli.sh -p "Explain quantum computing in simple terms"
```

That's it! You're ready to go.

---

### 📚 Alternative: Manual Setup

If you prefer manual control:

1. **Get an API key:**
   - [OpenAI](https://platform.openai.com/api-keys) (ChatGPT) - Free tier available
   - [Google AI](https://ai.google.dev/) (Gemini) - Free tier available

2. **Install dependencies:**
   ```bash
   pkg install curl jq  # On Termux
   # OR
   sudo apt install curl jq  # On Debian/Ubuntu
   ```

3. **Configure your API key:**
   ```bash
   mkdir -p ~/.config/termux-ai
   cp 01_env_template.sh ~/.config/termux-ai/env
   nano ~/.config/termux-ai/env  # Add your API key
   ```

4. **Test it:**
   ```bash
   bash 00_check_env.sh
   ```

---

### 🎯 Interactive Learning

New to the toolkit? Run the interactive guide:

```bash
bash quick_start.sh
```

This provides:
- Hands-on examples and demos
- Step-by-step tutorials
- Real-time AI interactions
- Tips and tricks

---

### 📝 Example Prompts Library

Not sure what to ask? Check out the `examples/` directory:

```bash
# Use ready-made prompts
bash ai_cli.sh -f examples/code_review.txt

# Browse all examples
ls examples/
```

Available examples:
- Code review and debugging
- Email drafting
- Git commit messages
- Documentation generation
- API design
- And more!

---

## Usage Examples

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

## Development

### Running Tests

```bash
bash tests.sh
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
