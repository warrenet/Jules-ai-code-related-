# ADR-0002: Firebase for Agent Builder Cloud Sync

**Date**: 2024-11-15

**Status**: Accepted

**Deciders**: Repository maintainers

**Technical Story**: Enabling cloud storage for the Agent Builder web application

---

### Context and Problem Statement

The Agent Builder web application (index.html + script.js) allows users to design AI agent prompts visually. We need to provide:
- A way to save and load agent configurations
- Access from multiple devices
- Optional cloud sync (not mandatory)
- Simple implementation without backend server

### Decision Drivers

* **No backend requirement**: Should work offline/locally by default
* **Easy setup**: Users shouldn't need complex infrastructure
* **Cross-device sync**: Optional ability to access from multiple devices
* **Free tier availability**: Should be accessible without cost
* **Simple integration**: Minimal code changes
* **Privacy**: Users control their data

### Considered Options

* **Firebase (Firestore + Auth)** - Google's BaaS platform
* **LocalStorage only** - Browser-based storage
* **GitHub Gists** - Version-controlled snippets
* **Custom backend** - Self-hosted server

### Decision Outcome

Chosen option: **Firebase with localStorage fallback**, because:
- Works offline by default (localStorage)
- Optional Firebase enables cloud sync
- Free tier is generous (Spark plan)
- No backend server to maintain
- Anonymous auth protects privacy
- Simple JavaScript SDK

#### Positive Consequences

* **Works offline**: Default localStorage mode requires nothing
* **Easy optional upgrade**: Add Firebase config to enable sync
* **No server maintenance**: Fully managed service
* **Free for most users**: Spark plan covers typical usage
* **Cross-device access**: When Firebase configured
* **Privacy friendly**: Anonymous auth, user owns data

#### Negative Consequences

* **Vendor lock-in**: Tied to Google Firebase
* **Configuration required**: Users must set up Firebase project for sync
* **Privacy concerns**: Data stored on Google servers (when using sync)
* **Internet dependency**: Cloud sync requires connection
* **Cost for heavy users**: May exceed free tier

### Implementation Details

The Agent Builder:
1. Uses localStorage by default (works offline, no setup)
2. Detects Firebase config in code
3. If configured, offers cloud sync features
4. Falls back to localStorage if Firebase unavailable

Users can:
- Use locally without any Firebase setup
- Optionally configure Firebase for cloud sync
- Export/import JSON configurations manually

### Configuration

To enable Firebase sync:
1. Create Firebase project
2. Enable Firestore and Anonymous Auth
3. Update Firebase config in `index.html`
4. Features automatically enable

### Links

* Implements: Agent Builder visual workflow design
* Related: Uses vanilla JavaScript (no framework dependencies)
