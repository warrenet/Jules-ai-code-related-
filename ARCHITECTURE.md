# Architecture & Design

This document explains the structure and design philosophy of the Termux AI Toolkit.

## Repository Structure

```
termux-ai-toolkit/
├── Core Scripts (Termux AI CLI Tools)
│   ├── termux-ai              - Unified launcher (entry point)
│   ├── ai_cli.sh              - Core AI interaction engine
│   ├── clip_summarize.sh      - Clipboard summarization wrapper
│   ├── url_summarize.sh       - URL content summarization wrapper
│   ├── file_summarize.sh      - File summarization wrapper
│   ├── 00_check_env.sh        - Environment diagnostics
│   └── install_toolkit.sh     - Self-contained installer
│
├── Web Application (Agent Builder)
│   ├── index.html             - Main web interface
│   └── script.js              - Frontend logic (Firebase, drag-drop)
│
├── Configuration & Setup
│   ├── 01_env_template.sh     - Environment configuration template
│   └── .gitignore             - Ignore patterns
│
├── Documentation
│   ├── README.md              - Main documentation
│   ├── QUICKSTART.md          - 5-minute getting started guide
│   ├── README_first.md        - Detailed user guide
│   ├── CONTRIBUTING.md        - Contribution guidelines
│   ├── optional_widget_setup.md - Android home screen widgets
│   ├── ARCHITECTURE.md        - This file
│   └── LICENSE                - MIT License
│
└── Testing
    └── tests.sh               - Automated test suite
```

## Design Philosophy

### 1. Safety First

All scripts follow a "non-destructive by default" approach:

- **DRY_RUN=1** by default - scripts won't write files unless explicitly allowed
- **Isolated workspace** - all outputs go to `~/.local/share/termux-ai/`
- **No automatic system changes** - never installs packages or modifies system files without permission
- **API key protection** - keys are masked in all logs and error messages

### 2. Simplicity & Transparency

- **Pure Bash** - no hidden dependencies, easy to read and audit
- **Minimal dependencies** - only `curl` and `jq` required
- **Heavily commented** - code is self-documenting
- **No magic** - clear, straightforward implementation

### 3. Unix Philosophy

- **Do one thing well** - each script has a single, clear purpose
- **Composable** - scripts can be piped and chained
- **Text-based** - works with standard Unix tools
- **Small & focused** - easy to understand and modify

## Component Details

### Unified Launcher (`termux-ai`)

The launcher provides a consistent interface across all toolkit commands:

```bash
termux-ai <command> [options]
```

**Benefits:**
- Single entry point for all functionality
- Consistent command structure
- Easy to remember and use
- Built-in help system

**Commands:**
- `ask` → `ai_cli.sh`
- `clip` → `clip_summarize.sh`
- `url` → `url_summarize.sh`
- `file` → `file_summarize.sh`
- `check` → `00_check_env.sh`
- `test` → `tests.sh`

### Core Engine (`ai_cli.sh`)

The heart of the toolkit, handling all AI provider interactions.

**Features:**
- Multi-provider support (OpenAI, Gemini)
- Streaming responses for real-time output
- Automatic provider detection
- Cost estimation and warnings
- Flexible input sources (stdin, file, URL, direct)

**Flow:**
1. Parse arguments and validate inputs
2. Detect and select AI provider
3. Load API credentials
4. Estimate costs and warn if needed
5. Make streaming API call
6. Display results in real-time
7. Optionally save output

### Wrapper Scripts

Specialized scripts that call `ai_cli.sh` with preset configurations:

**`clip_summarize.sh`**
- Uses `termux-clipboard-get` to read clipboard
- Passes content to AI with summarization prompt
- Requires Termux:API

**`url_summarize.sh`**
- Fetches URL content with `curl`
- Handles large documents via chunking
- Smart content extraction

**`file_summarize.sh`**
- Reads local files
- Validates file existence and permissions
- Supports large file handling

### Environment Checker (`00_check_env.sh`)

Diagnostic tool that validates:
- Required commands (`curl`, `jq`)
- Optional tools (`termux-clipboard-get`)
- Internet connectivity
- API key configuration
- File permissions

**Output:**
- ✓ Green checks for OK
- ⚠ Yellow warnings for optional issues
- ✗ Red errors for critical problems

### Test Suite (`tests.sh`)

Automated testing framework with:
- Mock environment setup
- Unit tests for each component
- Integration tests
- Color-coded output
- Exit codes for CI/CD

**Tests:**
1. Help flag functionality
2. Argument validation
3. Environment checking
4. Script existence
5. Launcher help
6. Launcher version
7. (Future: API call mocking)

## Data Flow

### Typical AI Request Flow

```
User Input
    ↓
termux-ai launcher (optional)
    ↓
ai_cli.sh
    ↓
[Validate] → [Load Config] → [Detect Provider]
    ↓
[Prepare Payload] → [Make API Call]
    ↓
[Stream Response] ← ← ← [AI Provider]
    ↓
[Display to User] + [Save to File (if DRY_RUN=0)]
    ↓
Exit
```

### Configuration Loading

```
ai_cli.sh startup
    ↓
Check for ~/.config/termux-ai/env
    ↓
If exists: source environment variables
    ↓
Check for OPENAI_API_KEY or GEMINI_API_KEY
    ↓
Select provider based on available keys
    ↓
Use default models if not specified
```

## Security Considerations

### API Key Handling

1. **Storage**: Keys stored in `~/.config/termux-ai/env`
2. **Permissions**: User's home directory (700 recommended)
3. **Logging**: Always masked in output (`sk-****`)
4. **Transmission**: HTTPS only to official endpoints
5. **Scope**: Never committed to git (.gitignore)

### Input Validation

All user inputs are validated:
- File paths checked for existence
- URLs validated before fetching
- Special characters handled safely
- Command injection prevented

### Network Safety

- HTTPS enforced for all API calls
- Timeouts prevent hanging (default 60s)
- Error handling for network failures
- No automatic retries (explicit user control)

## Extension Points

### Adding New AI Providers

To add a new provider (e.g., Claude, Llama):

1. Add API key variable to `01_env_template.sh`
2. Create provider function in `ai_cli.sh`:
   ```bash
   provider_name_call() {
       local prompt="$1" system_prompt="$2" model="$3" api_key="$4"
       # Implementation
   }
   ```
3. Add detection logic in main()
4. Update documentation

### Adding New Commands

To add a new specialized script:

1. Create script (e.g., `new_feature.sh`)
2. Make it executable: `chmod +x new_feature.sh`
3. Add wrapper in `termux-ai` launcher
4. Add test in `tests.sh`
5. Update documentation

### Widget Integration

See `optional_widget_setup.md` for creating Termux:Widget shortcuts.

## Agent Builder Web App

### Architecture

- **Frontend**: Vanilla JavaScript (no frameworks)
- **UI**: Tailwind CSS + Font Awesome
- **Drag & Drop**: SortableJS
- **Storage**: Firebase Firestore (optional) or localStorage
- **Auth**: Firebase Anonymous Auth

### Components

1. **Toolbox**: Pre-defined block types
2. **Canvas**: Drag-drop workspace
3. **Editor Modal**: Block content editing
4. **Preview Modal**: Complete prompt generation
5. **Save/Load**: Persistence layer

### Data Model

```javascript
{
  blocks: [
    {
      id: "unique-id",
      type: "system|user|context|tool",
      content: "Block text content",
      order: 0
    }
  ],
  metadata: {
    name: "Agent Name",
    description: "Agent Description",
    created: timestamp,
    modified: timestamp
  }
}
```

## Performance Considerations

### Optimization Strategies

1. **Streaming**: Real-time output, no waiting for complete response
2. **Chunking**: Large files processed in segments
3. **Bash native**: Parameter expansion over external commands
4. **Minimal pipes**: Reduce process creation overhead
5. **Local caching**: Store API responses when appropriate

### Resource Usage

- **Memory**: Minimal (< 10MB for typical use)
- **Disk**: Only output files (user controlled)
- **Network**: Only during API calls
- **CPU**: Low (mainly I/O bound)

## Future Enhancements

See `README.md` Roadmap section for planned features:

- Additional AI providers (Claude, Llama)
- Conversation history/context
- Voice input via Termux:API
- Image analysis support
- Code execution sandbox
- Multi-language UI

## Contributing

See `CONTRIBUTING.md` for:
- Code style guidelines
- Testing requirements
- Pull request process
- Security considerations

---

**Questions?** Open an issue on GitHub or check the documentation files.
