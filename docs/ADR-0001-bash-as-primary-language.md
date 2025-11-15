# ADR-0001: Use Bash as Primary Language

**Date**: 2024-11-15

**Status**: Accepted

**Deciders**: Repository maintainers

**Technical Story**: Choosing the implementation language for the Termux AI Toolkit

---

### Context and Problem Statement

The Termux AI Toolkit needs to run on Android devices through Termux, a terminal emulator that provides a Linux-like environment. We need to choose a primary programming language that:
- Works reliably in Termux
- Has minimal dependencies
- Is easy to maintain and understand
- Can make HTTP API calls
- Can process JSON responses

### Decision Drivers

* **Termux compatibility**: Must work natively in Termux without complex setup
* **Minimal dependencies**: Termux has limited package availability
* **Maintainability**: Scripts should be easy to read and modify
* **API integration**: Need to call REST APIs (OpenAI, Gemini)
* **JSON processing**: Must parse and generate JSON
* **User base**: Target users are familiar with shell scripting

### Considered Options

* **Bash** - Unix shell scripting language
* **Python** - High-level programming language
* **Node.js** - JavaScript runtime
* **Go** - Compiled programming language

### Decision Outcome

Chosen option: **Bash**, because:
- Native to Termux (no installation required)
- Minimal dependencies (only curl and jq needed)
- Universally available on all Linux systems
- Perfect for scripting and automation
- Easy to audit and understand
- Aligns with Unix philosophy

#### Positive Consequences

* **Zero setup**: Scripts run immediately in Termux
* **Small footprint**: No runtime installation needed
* **Easy debugging**: Users can read and understand the code
* **Fast execution**: No interpreter warmup time
* **Composable**: Can be piped with other Unix tools
* **Auditable**: Users can verify no malicious code

#### Negative Consequences

* **Limited libraries**: Can't use rich ecosystems like npm or PyPI
* **Error handling**: Bash error handling is more verbose
* **Type safety**: No static type checking
* **Complex data structures**: JSON manipulation less elegant than Python
* **Testing**: Limited testing frameworks available

### Implementation Details

We mitigate the negative consequences by:
- Using `set -Eeuo pipefail` for strict error handling
- Leveraging `jq` for robust JSON processing
- Creating modular functions with clear interfaces
- Providing comprehensive test suite
- Following shellcheck recommendations

### Links

* Related: [ADR-0003: Map-Reduce for Large Documents](ADR-0003-map-reduce-pattern.md)
