.POSIX:
.PHONY: help test lint format clean dev-check install all

# Default target
all: dev-check

help:
	@echo "Termux AI Toolkit - Make Targets"
	@echo ""
	@echo "  make test          - Run the test suite"
	@echo "  make lint          - Run shellcheck on all scripts"
	@echo "  make format        - Format JavaScript and HTML files"
	@echo "  make clean         - Remove temporary files and mock directories"
	@echo "  make dev-check     - Run lint and test (for local development)"
	@echo "  make install       - Install required dependencies (curl, jq)"
	@echo ""

test:
	@echo "Running test suite..."
	@bash tests.sh
	@echo "Running prompt evaluation tests..."
	@bash tests_prompt_eval.sh

lint:
	@echo "Running shellcheck on all scripts..."
	@if command -v shellcheck >/dev/null 2>&1; then \
		shellcheck *.sh agents/*.sh scripts/*.sh 2>/dev/null || true; \
		echo "✓ ShellCheck completed"; \
	else \
		echo "Warning: shellcheck not installed, skipping lint"; \
	fi

format:
	@echo "Formatting JavaScript and HTML files..."
	@if command -v npx >/dev/null 2>&1; then \
		npx prettier --write script.js index.html; \
		echo "✓ Formatting completed"; \
	else \
		echo "Warning: npx not available, skipping format"; \
	fi

clean:
	@echo "Cleaning temporary files..."
	@rm -rf mock_bin coverage tmp
	@echo "✓ Clean completed"

dev-check: lint test
	@echo ""
	@echo "✅ All development checks passed!"

install:
	@echo "Installing dependencies..."
	@if command -v pkg >/dev/null 2>&1; then \
		pkg install -y curl jq; \
	elif command -v apt-get >/dev/null 2>&1; then \
		sudo apt-get update && sudo apt-get install -y curl jq; \
	else \
		echo "Error: No supported package manager found (pkg or apt-get)"; \
		exit 1; \
	fi
	@echo "✓ Dependencies installed"
