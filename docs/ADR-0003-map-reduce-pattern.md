# ADR-0003: Map-Reduce Pattern for Large Documents

**Date**: 2024-11-15

**Status**: Accepted

**Deciders**: Repository maintainers

**Technical Story**: Handling documents larger than AI model context windows

---

### Context and Problem Statement

AI models have limited context windows (typically 4K-128K tokens). When users want to summarize large documents:
- Documents may exceed the model's context limit
- Sending everything at once may fail
- Need to preserve document coherence
- Cost considerations for API usage

### Decision Drivers

* **Context limits**: Must handle documents larger than model limits
* **Quality**: Summaries should be coherent, not just truncated
* **Cost efficiency**: Minimize API calls while maintaining quality
* **User experience**: Automatic handling, no manual chunking
* **Accuracy**: Preserve important information
* **Simplicity**: Implementation in Bash

### Considered Options

* **Truncation** - Simply cut off at token limit
* **Sliding window** - Process overlapping chunks
* **Map-reduce** - Chunk, summarize each, then synthesize
* **Hierarchical summarization** - Multi-level summarization tree

### Decision Outcome

Chosen option: **Map-reduce pattern**, because:
- Handles arbitrary document sizes
- Preserves information from entire document
- Balances cost with quality
- Simple to implement in Bash
- Proven pattern for distributed processing

#### Positive Consequences

* **Scalable**: Handles documents of any size
* **Information preservation**: Entire document processed
* **Cost aware**: Users see warnings for large inputs
* **Automatic**: No manual intervention required
* **Parallelizable**: Could add concurrent processing later
* **Quality**: Final summary considers whole document

#### Negative Consequences

* **Multiple API calls**: More expensive than single call
* **Latency**: Takes longer for large documents
* **Potential information loss**: Intermediate summaries may lose details
* **Complexity**: More moving parts than simple truncation

### Implementation Details

The map-reduce process:

1. **Estimate tokens**: Check document size
2. **Warn user**: If document exceeds threshold (~8000 tokens)
3. **Chunk**: Split document into manageable pieces
4. **Map**: Summarize each chunk independently
5. **Reduce**: Synthesize chunk summaries into final summary

Example from `url_summarize.sh`:
```bash
# Map phase: summarize chunks
for chunk in chunk_*.txt; do
    summarize_chunk "$chunk" > "summary_$chunk"
done

# Reduce phase: synthesize summaries
cat summary_chunk_*.txt | synthesize_final_summary
```

### Token Estimation

We estimate tokens conservatively:
- 1 token ≈ 4 characters for English
- Add 20% safety margin
- Warn at 8000 tokens (well under limits)
- Chunk at ~4000 tokens for overlap

### Cost Implications

For an 80,000 token document:
- Without map-reduce: Would fail or be truncated
- With map-reduce: ~20 chunks × 2 (map + reduce) = 40 API calls
- User is warned and must confirm for >8000 tokens

### Links

* Implements: `url_summarize.sh` and `file_summarize.sh`
* Related: [ADR-0001: Bash as Primary Language](ADR-0001-bash-as-primary-language.md)
* Pattern: Classical map-reduce for distributed processing
