# Prompt Evaluation System Architecture

## Component Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        ai_cli.sh (Main CLI)                     │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  User Input Processing                                    │  │
│  │  • Parse arguments                                        │  │
│  │  • Validate inputs                                        │  │
│  │  • Load configuration                                     │  │
│  └───────────────────────────────────────────────────────────┘  │
│                            ↓                                     │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  Prompt Evaluation Hook (PROMPT_EVALUATION=1)             │  │
│  │  • Check if evaluation enabled                            │  │
│  │  • Source hooks/prompt_evaluator.sh                       │  │
│  │  • Call evaluate_prompt()                                 │  │
│  └───────────────────────────────────────────────────────────┘  │
│                            ↓                                     │
│              ┌─────────────┴─────────────┐                       │
│              │                           │                       │
│         ┌────▼─────┐                ┌───▼────┐                  │
│         │  VAGUE   │                │ CLEAR  │                  │
│         └────┬─────┘                └───┬────┘                  │
│              │                          │                       │
│  ┌───────────▼────────────────┐        │                       │
│  │ Invoke Prompt Improver     │        │                       │
│  │ • Source skills/           │        │                       │
│  │   prompt_improver.sh       │        │                       │
│  │ • Call improve_prompt()    │        │                       │
│  └───────────┬────────────────┘        │                       │
│              │                          │                       │
│  ┌───────────▼────────────────┐        │                       │
│  │ Research & Questions       │        │                       │
│  │ • Create research plan     │        │                       │
│  │ • Execute research         │        │                       │
│  │ • Generate questions       │        │                       │
│  │ • Collect user answers     │        │                       │
│  │ • Improve prompt           │        │                       │
│  └───────────┬────────────────┘        │                       │
│              │                          │                       │
│              └──────────┬───────────────┘                       │
│                         ↓                                       │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  Execute AI API Call                                      │  │
│  │  • OpenAI or Gemini                                       │  │
│  │  • Stream response                                        │  │
│  │  • Save output (if DRY_RUN=0)                             │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## Sequence Flow

```
User               Hook                Claude              Skill               Project
 │                  │                    │                   │                   │
 │ "fix the bug"   │                    │                   │                   │
 ├─────────────────>│                    │                   │                   │
 │                  │ Eval prompt        │                   │                   │
 │                  │ (~189 tokens)      │                   │                   │
 │                  ├───────────────────>│                   │                   │
 │                  │                    │                   │                   │
 │                  │ Evaluate using     │                   │                   │
 │                  │ conversation       │                   │                   │
 │                  │ history            │                   │                   │
 │                  │<───────────────────┤                   │                   │
 │                  │                    │                   │                   │
 │                  │                    │                   │                   │
 │              ┌───┴───┐                │                   │                   │
 │              │VAGUE? │                │                   │                   │
 │              └───┬───┘                │                   │                   │
 │                  │                    │                   │                   │
 │         ┌────────┴────────┐           │                   │                   │
 │         │                 │           │                   │                   │
 │      [YES]             [NO]           │                   │                   │
 │         │                 │           │                   │                   │
 │         │                 │           │                   │                   │
 │         │                 └──────────────────────────────────────────────────>│
 │         │                             │                   │              Execute
 │         │                             │                   │              immediately
 │         │                             │                   │                   │
 │         │                             │                   │                   │
 │         │ Invoke skill                │                   │                   │
 │         ├─────────────────────────────┴──────────────────>│                   │
 │         │                                                 │                   │
 │         │                                    Create plan  │                   │
 │         │                                    (TodoWrite)  │                   │
 │         │                                                 │                   │
 │         │                                                 │ Research          │
 │         │                                                 ├──────────────────>│
 │         │                                                 │                   │
 │         │                                                 │ • Codebase        │
 │         │                                                 │ • Docs            │
 │         │                                                 │ • Web             │
 │         │                                                 │                   │
 │         │                                                 │<──────────────────┤
 │         │                                    Context      │                   │
 │         │                                                 │                   │
 │         │                                    Generate     │                   │
 │         │                                    questions    │                   │
 │         │                                    (1-6)        │                   │
 │         │                                                 │                   │
 │         │<────────────────────────────────────────────────┤                   │
 │         │ Questions                                       │                   │
 │         │                                                 │                   │
 │<────────┤                                                 │                   │
 │ Display │                                                 │                   │
 │ questions                                                 │                   │
 │         │                                                 │                   │
 │ Answers │                                                 │                   │
 │─────────>│                                                 │                   │
 │         │                                                 │                   │
 │         │ Append to                                       │                   │
 │         │ original                                        │                   │
 │         │ prompt                                          │                   │
 │         │                                                 │                   │
 │         │                             │                   │                   │
 │         └─────────────────────────────┼───────────────────┼──────────────────>│
 │                                       │                   │              Execute
 │                                  Execute with             │              with
 │                                  improved prompt          │              improved
 │                                       │                   │              prompt
 │                                       │                   │                   │
```

## File Structure

```
termux-ai-toolkit/
├── ai_cli.sh                      # Main CLI (modified)
│   └── [Prompt Evaluation Hook]   # Lines 271-340
│
├── hooks/
│   └── prompt_evaluator.sh        # NEW: Vague/Clear detection
│       ├── evaluate_prompt()
│       ├── call_openai_eval()
│       └── call_gemini_eval()
│
├── skills/
│   └── prompt_improver.sh         # NEW: Research & Questions
│       ├── improve_prompt()
│       ├── create_research_plan()
│       ├── execute_research()
│       │   ├── research_codebase()
│       │   ├── research_web()
│       │   └── research_documentation()
│       └── generate_questions()
│
├── tests_prompt_eval.sh           # NEW: Test suite
│
├── demo_prompt_eval.sh            # NEW: Interactive demo
│
├── PROMPT_EVALUATION.md           # NEW: User guide
│
├── IMPLEMENTATION_SUMMARY.md      # NEW: Technical doc
│
└── 01_env_template.sh             # Modified: +PROMPT_EVALUATION
```

## Data Flow

```
Input Prompt
     ↓
[Evaluation]
     ↓
  Result (VAGUE/CLEAR)
     ↓
     ├── VAGUE ────────→ [Research Plan]
     │                         ↓
     │                   [Execute Research]
     │                         ↓
     │                    [Context Data]
     │                         ↓
     │                   [Generate Questions]
     │                         ↓
     │                    [User Answers]
     │                         ↓
     │                   [Improved Prompt]
     │                         ↓
     └── CLEAR ──────────────→ [Original Prompt]
                               ↓
                          [AI API Call]
                               ↓
                          [Response]
```

## Performance Characteristics

```
┌──────────────┬─────────────┬──────────────┬───────────┐
│ Scenario     │ API Calls   │ Time (sec)   │ Cost      │
├──────────────┼─────────────┼──────────────┼───────────┤
│ Clear Prompt │ 1 (eval) +  │ 0.5-2        │ Low       │
│              │ 1 (exec)    │              │           │
├──────────────┼─────────────┼──────────────┼───────────┤
│ Vague Prompt │ 1 (eval) +  │ 3-8          │ Moderate  │
│              │ 1 (plan) +  │              │           │
│              │ 1 (questions)│             │           │
│              │ + 1 (exec)  │              │           │
├──────────────┼─────────────┼──────────────┼───────────┤
│ Disabled     │ 1 (exec)    │ 0            │ Minimal   │
│ (PROMPT_     │             │              │           │
│ EVALUATION=0)│             │              │           │
└──────────────┴─────────────┴──────────────┴───────────┘
```

## Configuration Options

```
┌─────────────────────┬──────────┬─────────────────────────┐
│ Variable            │ Default  │ Description             │
├─────────────────────┼──────────┼─────────────────────────┤
│ PROMPT_EVALUATION   │ 1        │ Enable/disable system   │
│ PROVIDER            │ (auto)   │ openai or gemini        │
│ AI_TIMEOUT          │ 60       │ API timeout (seconds)   │
│ DRY_RUN             │ 1        │ Prevent file writes     │
└─────────────────────┴──────────┴─────────────────────────┘
```

## Error Handling

```
┌──────────────────────┬──────────────────────────────────┐
│ Error Scenario       │ Fallback Behavior                │
├──────────────────────┼──────────────────────────────────┤
│ Evaluation fails     │ Default to "CLEAR", proceed      │
│ Improver fails       │ Skip questions, use original     │
│ Research fails       │ Continue with limited context    │
│ Question gen fails   │ Use generic questions or skip    │
│ Network timeout      │ Retry or fail gracefully         │
│ Invalid API key      │ Error message, exit              │
└──────────────────────┴──────────────────────────────────┘
```
