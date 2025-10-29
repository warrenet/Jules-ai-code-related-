# Example Prompts Library

This directory contains ready-to-use example prompts for common tasks. You can use these directly or modify them for your needs.

## How to Use

### Method 1: Direct Use
```bash
bash ai_cli.sh -f examples/code_review.txt
```

### Method 2: Customize and Use
```bash
# Copy an example
cp examples/email_template.txt my_email.txt

# Edit it with your content
nano my_email.txt

# Run it
bash ai_cli.sh -f my_email.txt
```

### Method 3: Pipe to AI
```bash
cat examples/brainstorm.txt | bash ai_cli.sh -p -
```

## Available Examples

- **code_review.txt** - Template for code review requests
- **email_template.txt** - Professional email drafting
- **learning_helper.txt** - Explain complex topics simply
- **brainstorm.txt** - Generate creative ideas
- **git_commit.txt** - Write commit messages
- **debugging.txt** - Debug code issues
- **documentation.txt** - Generate documentation
- **refactoring.txt** - Code improvement suggestions
- **testing.txt** - Generate test cases
- **api_design.txt** - API design assistance

## Creating Your Own

1. Create a new `.txt` file in this directory
2. Write your prompt or template
3. Use placeholders like `[YOUR_CODE_HERE]` for customization
4. Run it with `bash ai_cli.sh -f examples/your_file.txt`

## Tips

- Be specific in your prompts for better results
- Include context and constraints
- Ask for specific formats (bullet points, code, etc.)
- Iterate and refine based on results
