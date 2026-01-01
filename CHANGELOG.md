# Changelog

All notable changes to the Termux AI Toolkit will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-11-07

### Added
- **Unified Launcher**: New `termux-ai` command for easy access to all toolkit features
- **Version Support**: Added `--version` flag to display version information
- **QUICKSTART.md**: New 5-minute getting started guide for new users
- **ARCHITECTURE.md**: Comprehensive documentation of design and implementation
- **Enhanced Documentation**: Improved README with clear overview of both Termux CLI and Agent Builder components
- **Test Coverage**: Added tests for launcher functionality (9 tests total)
- **Agent Builder Documentation**: Detailed usage guide for the web-based agent builder

### Changed
- **Code Quality**: Fixed shellcheck warnings in ai_cli.sh and tests.sh
- **Performance**: Replaced `sed` with bash parameter expansion for better performance
- **Documentation**: Reorganized README with better structure and navigation
- **Help Text**: Improved usage messages across all scripts

### Fixed
- Unused variable warnings in ai_cli.sh
- PATH assignment issue in tests.sh to avoid masking return values
- Removed unused `--json` flag from ai_cli.sh

### Security
- All API keys properly masked in logs
- Input validation improved across all scripts

## [Pre-1.0.0] - Historical

### Features Available
- OpenAI GPT integration (GPT-4o, GPT-4o-mini)
- Google Gemini integration (1.5 Pro/Flash)
- Streaming AI responses
- Clipboard summarization (via Termux:API)
- URL content summarization
- File summarization
- Android home screen widgets support
- Non-destructive dry-run mode by default
- Environment diagnostic tool
- Self-contained installer
- Agent Builder web application
- Firebase integration for agent storage
- Drag-and-drop agent design interface

---

[1.0.0]: https://github.com/warrenet/termux-ai-toolkit/releases/tag/v1.0.0
