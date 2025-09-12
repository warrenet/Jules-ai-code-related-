import { initializeApp } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-app.js";
import { getAuth, signInAnonymously, signInWithCustomToken, onAuthStateChanged } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-auth.js";
import { getFirestore, doc, setDoc, getDoc, collection, onSnapshot, deleteDoc, writeBatch, getDocs, query, orderBy } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-firestore.js";

// --- Firebase Configuration and Initialization ---
const appId = typeof __app_id !== 'undefined' ? __app_id : 'default-agent-builder-app';
let firebaseConfig;
try {
    firebaseConfig = typeof __firebase_config !== 'undefined' ? JSON.parse(__firebase_config) : { apiKey: "DEMO", authDomain: "DEMO", projectId: "DEMO" };
} catch (e) {
    console.error("Firebase config parsing error:", e);
    firebaseConfig = { apiKey: "DEMO", authDomain: "DEMO", projectId: "DEMO" }; // Fallback
}

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);
const auth = getAuth(app);
let userId = null;

onAuthStateChanged(auth, async (user) => {
    if (user) {
        userId = user.uid;
        console.log("User authenticated with UID:", userId);
        setupRealtimeListener();
    } else {
        console.log("No user signed in. Signing in anonymously.");
        try {
            if (typeof __initial_auth_token !== 'undefined' && __initial_auth_token) {
                 await signInWithCustomToken(auth, __initial_auth_token);
            } else {
                await signInAnonymously(auth);
            }
        } catch (error) {
            console.error("Anonymous sign-in failed:", error);
        }
    }
});

// --- DOM Elements ---
const toolboxItems = document.querySelectorAll('.toolbox-item');
const canvas = document.getElementById('canvas');
const canvasPlaceholder = document.getElementById('canvas-placeholder');

const editModalBackdrop = document.getElementById('edit-modal-backdrop');
const editModal = document.getElementById('edit-modal');
const modalTitle = document.getElementById('modal-title');
const modalTextarea = document.getElementById('modal-textarea');
const closeModalBtn = document.getElementById('close-modal-btn');
const modalSaveBtn = document.getElementById('modal-save-btn');
const modalCancelBtn = document.getElementById('modal-cancel-btn');

const promptModalBackdrop = document.getElementById('prompt-modal-backdrop');
const promptModal = document.getElementById('prompt-modal');
const promptOutput = document.getElementById('prompt-output');
const copyPromptBtn = document.getElementById('copy-prompt-btn');
const closePromptModalBtn = document.getElementById('close-prompt-modal-btn');
const promptDoneBtn = document.getElementById('prompt-done-btn');

const confirmModal = document.getElementById('confirm-modal');
const confirmModalText = document.getElementById('confirm-modal-text');
const confirmModalOkBtn = document.getElementById('confirm-modal-ok-btn');
const confirmModalCancelBtn = document.getElementById('confirm-modal-cancel-btn');

const saveModal = document.getElementById('save-modal');
const saveModalInput = document.getElementById('save-modal-input');
const saveModalError = document.getElementById('save-modal-error');
const saveModalSaveBtn = document.getElementById('save-modal-save-btn');
const saveModalCancelBtn = document.getElementById('save-modal-cancel-btn');

const mainActionsContainer = document.getElementById('main-actions');
let loadContainer; // Will be created dynamically

let currentEditingBlock = null;

// ---
// History Management: Handles undo/redo functionality by storing snapshots of the canvas state.
// ---
const historyManager = {
    history: [],
    historyIndex: -1,

    init(initialState) {
        this.history = [JSON.stringify(initialState)];
        this.historyIndex = 0;
        this.updateButtons();
    },

    pushState(state) {
        // If we are in the middle of the history, chop off the future states
        if (this.historyIndex < this.history.length - 1) {
            this.history = this.history.slice(0, this.historyIndex + 1);
        }
        // Don't push duplicates
        if (this.history[this.historyIndex] === JSON.stringify(state)) return;

        this.history.push(JSON.stringify(state));
        this.historyIndex++;
        this.updateButtons();
    },

    undo() {
        if (this.canUndo()) {
            this.historyIndex--;
            this.updateButtons();
            return JSON.parse(this.history[this.historyIndex]);
        }
        return null;
    },

    redo() {
        if (this.canRedo()) {
            this.historyIndex++;
            this.updateButtons();
            return JSON.parse(this.history[this.historyIndex]);
        }
        return null;
    },

    canUndo() {
        return this.historyIndex > 0;
    },

    canRedo() {
        return this.historyIndex < this.history.length - 1;
    },

    updateButtons() {
        const undoBtn = document.getElementById('undo-btn');
        const redoBtn = document.getElementById('redo-btn');
        if (undoBtn) undoBtn.disabled = !this.canUndo();
        if (redoBtn) redoBtn.disabled = !this.canRedo();
    }
};

// ---
// Core Functions: Main application logic for creating and managing blocks and modals.
// ---
const updateCanvasPlaceholder = () => {
    const hasItems = canvas.querySelector('.canvas-item');
    canvasPlaceholder.style.display = hasItems ? 'none' : 'flex';
};

const createBlockElement = (blockData) => {
    const { id, type, title, icon, content, blocks } = blockData;

    const div = document.createElement('div');
    div.className = `canvas-item bg-gray-800/80 border border-gray-700 rounded-lg p-4 shadow-lg flex items-start space-x-4`;
    div.dataset.id = id;
    div.dataset.type = type;
    div.dataset.title = title;
    div.dataset.icon = icon;

    if (type === 'group') {
        div.innerHTML = `
            <i class="fas ${icon} text-xl text-gray-400 pt-1 cursor-grab active:cursor-grabbing"></i>
            <div class="flex-1 overflow-hidden">
                <div class="flex justify-between items-center">
                    <h3 class="font-bold text-white">${title}</h3>
                    <div class="flex items-center space-x-2">
                        <button class="collapse-btn text-gray-400 hover:text-white transition-colors w-6 h-6 flex items-center justify-center"><i class="fas fa-chevron-up"></i></button>
                        <button class="delete-btn text-gray-400 hover:text-red-400 transition-colors w-6 h-6 flex items-center justify-center"><i class="fas fa-trash-alt"></i></button>
                    </div>
                </div>
                <div class="collapsible-content">
                    <div class="group-container min-h-[50px] bg-gray-900/50 mt-2 p-2 rounded-md border border-dashed border-gray-600 space-y-2">
                        <!-- Nested blocks go here -->
                    </div>
                </div>
            </div>
        `;
        const groupContainer = div.querySelector('.group-container');
        new Sortable(groupContainer, {
            group: 'shared',
            animation: 150,
            onAdd: () => recordCanvasChange(() => {}),
            onEnd: () => recordCanvasChange(() => {})
        });
        if (blocks) {
            blocks.forEach(childBlockData => {
                groupContainer.appendChild(createBlockElement(childBlockData));
            });
        }
    } else {
        div.innerHTML = `
            <i class="fas ${icon} text-xl text-gray-400 pt-1 cursor-grab active:cursor-grabbing"></i>
            <div class="flex-1 overflow-hidden">
                <div class="flex justify-between items-center">
                    <h3 class="font-bold text-white">${title}</h3>
                    <div class="flex items-center space-x-2">
                        <button class="collapse-btn text-gray-400 hover:text-white transition-colors w-6 h-6 flex items-center justify-center"><i class="fas fa-chevron-up"></i></button>
                        <button class="edit-btn text-gray-400 hover:text-blue-400 transition-colors w-6 h-6 flex items-center justify-center"><i class="fas fa-pencil-alt"></i></button>
                        <button class="delete-btn text-gray-400 hover:text-red-400 transition-colors w-6 h-6 flex items-center justify-center"><i class="fas fa-trash-alt"></i></button>
                    </div>
                </div>
                <div class="collapsible-content">
                    <p class="content-preview text-sm text-gray-300 mt-2 pr-2">${content || 'Click to configure...'}</p>
                </div>
            </div>
        `;
        div.dataset.content = content || '';
        div.dataset.placeholder = blockData.placeholder || 'Enter your instructions here...';
        div.querySelector('.edit-btn').addEventListener('click', () => openEditModal(div));
    }

    div.querySelector('.delete-btn').addEventListener('click', () => {
        recordCanvasChange(() => {
            div.remove();
            updateCanvasPlaceholder();
        });
    });
    div.querySelector('.collapse-btn').addEventListener('click', () => {
        const icon = div.querySelector('.collapse-btn i');
        div.classList.toggle('is-collapsed');
        if (div.classList.contains('is-collapsed')) {
            icon.classList.replace('fa-chevron-up', 'fa-chevron-down');
        } else {
            icon.classList.replace('fa-chevron-down', 'fa-chevron-up');
        }
    });

    return div;
};

const openModal = (modalEl) => {
    const backdrop = document.getElementById(`${modalEl.id}-backdrop`);
    modalEl.classList.add('show');
    backdrop.classList.add('show');
};

const closeModal = (modalEl) => {
    const backdrop = document.getElementById(`${modalEl.id}-backdrop`);
    modalEl.classList.remove('show');
    backdrop.classList.remove('show');
};

const openEditModal = (blockElement) => {
    currentEditingBlock = blockElement;
    modalTitle.innerHTML = `<i class="fas ${blockElement.dataset.icon} mr-2"></i> Configure ${blockElement.dataset.title}`;
    modalTextarea.value = blockElement.dataset.content || '';
    modalTextarea.placeholder = blockElement.dataset.placeholder || 'Enter your instructions here...';

    // --- Suggestion Logic Integration ---
    const suggestionBtn = document.getElementById('suggestion-btn');
    const suggestionPopover = document.getElementById('suggestion-popover');
    const applySuggestionBtn = document.getElementById('apply-suggestion-btn');

    // Reset and hide suggestion UI initially
    updateSuggestionUI(null);

    const debouncedGetSuggestion = debounce(async () => {
        if (suggestionState.isLoading) return;
        const suggestion = await getSuggestion(modalTextarea.value);
        updateSuggestionUI(suggestion);
    }, 1500); // 1.5 second debounce

    modalTextarea.addEventListener('input', debouncedGetSuggestion);

    suggestionBtn.onclick = () => { // Use onclick to easily overwrite
        suggestionPopover.classList.toggle('hidden');
    };

    applySuggestionBtn.onclick = () => {
        modalTextarea.value = suggestionState.suggestion;
        suggestionPopover.classList.add('hidden');
        suggestionBtn.classList.add('hidden'); // Hide after applying
    };
    // --- End Suggestion Logic ---

    openModal(editModal);
    setTimeout(() => {
        modalTextarea.focus();
        autoResizeTextarea(modalTextarea);
    }, 50);
    modalTextarea.addEventListener('input', () => autoResizeTextarea(modalTextarea));
};

const closeEditModal = () => {
    closeModal(editModal);
    currentEditingBlock = null;
};

const saveModalChanges = () => {
    if (currentEditingBlock) {
        recordCanvasChange(() => {
            const newContent = modalTextarea.value;
            currentEditingBlock.dataset.content = newContent;
            const preview = currentEditingBlock.querySelector('.content-preview');
            preview.textContent = newContent || 'Click to configure...';
            if (!newContent) {
               preview.classList.add('text-gray-500');
            } else {
               preview.classList.remove('text-gray-500');
            }
        });
    }
    closeEditModal();
};

// ---
// UI Helper Functions: Reusable components for modals, toasts, and other UI elements.
// ---
const autoResizeTextarea = (textarea) => {
    textarea.style.height = 'auto';
    textarea.style.height = `${textarea.scrollHeight}px`;
};

const showToast = (message, type = 'info') => {
    const toastContainer = document.getElementById('toast-container');
    const toast = document.createElement('div');
    const icons = { success: 'fa-check-circle', error: 'fa-times-circle', info: 'fa-info-circle' };
    const colors = { success: 'bg-green-600', error: 'bg-red-600', info: 'bg-blue-600' };

    toast.className = `flex items-center text-white px-4 py-3 rounded-md shadow-lg ${colors[type]} animate-toast-in`;
    toast.innerHTML = `<i class="fas ${icons[type]} mr-2"></i><p>${message}</p>`;

    toastContainer.appendChild(toast);

    setTimeout(() => {
        toast.classList.remove('animate-toast-in');
        toast.classList.add('animate-toast-out');
        toast.addEventListener('animationend', () => toast.remove());
    }, 3000);
};

const showConfirm = (text, onConfirm) => {
    confirmModalText.textContent = text;

    // Use .cloneNode(true) to remove any previous event listeners
    const newOkBtn = confirmModalOkBtn.cloneNode(true);
    confirmModalOkBtn.parentNode.replaceChild(newOkBtn, confirmModalOkBtn);

    const newCancelBtn = confirmModalCancelBtn.cloneNode(true);
    confirmModalCancelBtn.parentNode.replaceChild(newCancelBtn, confirmModalCancelBtn);

    const close = () => closeModal(confirmModal);

    newOkBtn.addEventListener('click', () => {
        close();
        onConfirm();
    });
    newCancelBtn.addEventListener('click', close);
    document.getElementById('confirm-modal-backdrop').addEventListener('click', close, { once: true });

    openModal(confirmModal);
};

const showSavePrompt = (onSave) => {
    saveModalInput.value = '';
    saveModalError.classList.add('hidden');

    const newSaveBtn = saveModalSaveBtn.cloneNode(true);
    saveModalSaveBtn.parentNode.replaceChild(newSaveBtn, saveModalSaveBtn);

    const newCancelBtn = saveModalCancelBtn.cloneNode(true);
    saveModalCancelBtn.parentNode.replaceChild(newCancelBtn, saveModalCancelBtn);

    const close = () => closeModal(saveModal);

    newSaveBtn.addEventListener('click', () => {
        const agentName = saveModalInput.value.trim();
        if (agentName) {
            close();
            onSave(agentName);
        } else {
            saveModalError.textContent = 'Please enter a valid name.';
            saveModalError.classList.remove('hidden');
        }
    });
    newCancelBtn.addEventListener('click', close);
    document.getElementById('save-modal-backdrop').addEventListener('click', close, { once: true });

    openModal(saveModal);
    setTimeout(() => saveModalInput.focus(), 50);
};


const getVariables = () => {
    const variables = {};
    const rows = document.querySelectorAll('#variables-container .flex');
    rows.forEach(row => {
        const keyInput = row.querySelector('.variable-key');
        const valueInput = row.querySelector('.variable-value');
        const key = keyInput.value.trim();
        if (key) {
            variables[key] = valueInput.value;
        }
    });
    return variables;
};

const generatePrompt = () => {
    const blocks = canvas.querySelectorAll('.canvas-item');
    if (blocks.length === 0) {
        showToast("Canvas is empty! Add some blocks first.", "error");
        return;
    }

    const variables = getVariables();
    const substituteVariables = (text) => {
        let substitutedText = text;
        for (const [key, value] of Object.entries(variables)) {
            // Use a regex to replace all occurrences of {{key}}
            const regex = new RegExp(`\\{\\{${key}\\}\\}`, 'g');
            substitutedText = substitutedText.replace(regex, value);
        }
        return substitutedText;
    };

    let promptText = "### AGENT CONFIGURATION ###\n\n";
    blocks.forEach(block => {
        const title = block.dataset.title.toUpperCase();
        let content = block.dataset.content || 'Not configured.';
        content = substituteVariables(content); // Substitute variables here
        promptText += `## ${title} ##\n${content}\n\n`;
    });
    promptOutput.textContent = promptText.trim();
    openModal(promptModal);
};

// ---
// Drag and Drop Logic: Initializes SortableJS for the toolbox and canvas.
// ---
const initDragAndDrop = () => {
    const toolboxContainer = document.getElementById('toolbox').querySelector('.space-y-3');

    // Initialize Sortable on the toolbox to clone items
    new Sortable(toolboxContainer, {
        group: {
            name: 'shared',
            pull: 'clone',
            put: false
        },
        animation: 150,
        sort: false // Do not sort items in the toolbox
    });

    // Initialize Sortable on the canvas to accept items and re-order them
    new Sortable(canvas, {
        group: 'shared',
        animation: 150,
        onAdd: function (evt) {
            recordCanvasChange(() => {
                const itemEl = evt.item; // The clone from the toolbox

                // Create a proper, functional canvas block from the toolbox item's data
                const blockData = {
                    id: `block-${Date.now()}`,
                    type: itemEl.dataset.type,
                    title: itemEl.dataset.title,
                    icon: itemEl.dataset.icon,
                    placeholder: itemEl.dataset.placeholder,
                    content: ''
                };
                const newBlock = createBlockElement(blockData);

                // Replace the static clone with our new functional block
                itemEl.parentNode.replaceChild(newBlock, itemEl);

                updateCanvasPlaceholder();
            });
        },
        onEnd: function (evt) {
            // This handles re-ordering within the canvas.
            recordCanvasChange(() => {
                updateCanvasPlaceholder();
            });
        }
    });
};

// ---
// Firestore Persistence: Functions for saving, loading, and deleting agent data from Firebase.
// ---
const getAgentDataFromCanvas = (rootElement = canvas) => {
    const blocks = [];
    // Use :scope to select only direct children, not nested ones
    rootElement.querySelectorAll(':scope > .canvas-item').forEach(el => {
        const blockData = {
            id: el.dataset.id,
            type: el.dataset.type,
            title: el.dataset.title,
            icon: el.dataset.icon,
            content: el.dataset.content || '',
            placeholder: el.dataset.placeholder || ''
        };

        if (blockData.type === 'group') {
            const groupContainer = el.querySelector('.group-container');
            blockData.blocks = getAgentDataFromCanvas(groupContainer); // Recursive call
        }

        blocks.push(blockData);
    });
    return blocks;
};

const loadAgentDataToCanvas = (agentData, recordHistory = true) => {
    const action = () => {
        canvas.innerHTML = ''; // Clear canvas
        if (agentData && agentData.length > 0) {
            agentData.forEach(blockData => {
                const newBlock = createBlockElement(blockData);
                canvas.appendChild(newBlock);
            });
        }
        updateCanvasPlaceholder();
    };

    if (recordHistory) {
        recordCanvasChange(action);
    } else {
        action();
    }
};

const saveAgent = async () => {
    if (!userId) {
        showToast("User not authenticated. Please wait.", "error");
        return;
    }

    showSavePrompt(async (agentName) => {
        const agentData = getAgentDataFromCanvas();
        if (agentData.length === 0) {
            showToast("Cannot save an empty canvas.", "error");
            return;
        }

        const agentRef = doc(db, `artifacts/${appId}/public/data/agents`, agentName);
        const versionRef = doc(collection(agentRef, 'versions')); // Create a new version doc with a unique ID

        try {
            const agentDoc = await getDoc(agentRef);

            const batch = writeBatch(db);

            // Write the actual agent data to the new version document
            batch.set(versionRef, { data: agentData, createdAt: new Date() });

            // Update the top-level agent document with metadata
            if (agentDoc.exists()) {
                batch.update(agentRef, { updatedAt: new Date(), latestVersionId: versionRef.id });
            } else {
                batch.set(agentRef, { name: agentName, createdAt: new Date(), updatedAt: new Date(), latestVersionId: versionRef.id });
            }

            await batch.commit();
            showToast(`Agent '${agentName}' saved successfully!`, "success");
        } catch (error) {
            console.error("Error saving agent:", error);
            showToast("Failed to save agent.", "error");
        }
    });
};

const loadAgent = async (agentName, versionId = null) => {
    if (!userId) {
        showToast("User not authenticated. Please wait.", "error");
        return;
    }

    const agentRef = doc(db, `artifacts/${appId}/public/data/agents`, agentName);
    try {
        const agentDoc = await getDoc(agentRef);
        if (!agentDoc.exists()) {
            showToast("Agent not found.", "error");
            return;
        }

        let versionToLoadId = versionId || agentDoc.data().latestVersionId;
        if (!versionToLoadId) {
            showToast("Agent has no saved versions.", "error");
            return;
        }

        const versionRef = doc(agentRef, 'versions', versionToLoadId);
        const versionDoc = await getDoc(versionRef);

        if (versionDoc.exists()) {
            const agentVersion = versionDoc.data();
            loadAgentDataToCanvas(agentVersion.data);
            const loadedMsg = versionId ? `Loaded version from ${new Date(agentVersion.createdAt.seconds * 1000).toLocaleString()}` : `Agent '${agentName}' loaded.`;
            showToast(loadedMsg, "info");
        } else {
            showToast("Could not find the specified agent version.", "error");
        }
    } catch (error) {
        console.error("Error loading agent:", error);
        showToast("Failed to load agent.", "error");
    }
};

const deleteAgent = async (agentName) => {
    if (!userId) {
        showToast("User not authenticated. Please wait.", "error");
        return;
    }

    showConfirm(`Are you sure you want to delete the agent '${agentName}' and all its versions? This cannot be undone.`, async () => {
        const agentRef = doc(db, `artifacts/${appId}/public/data/agents`, agentName);
        const versionsCol = collection(agentRef, 'versions');

        try {
            const versionsSnapshot = await getDocs(versionsCol);
            const batch = writeBatch(db);

            // Delete all version sub-documents
            versionsSnapshot.forEach(doc => {
                batch.delete(doc.ref);
            });

            // Delete the parent agent document
            batch.delete(agentRef);

            await batch.commit();
            showToast(`Agent '${agentName}' deleted.`, "success");
        } catch (e) {
            console.error("Error deleting agent: ", e);
            showToast("Failed to delete agent.", "error");
        }
    });
}

const setupRealtimeListener = () => {
     if (!userId) return;
     const agentsCol = collection(db, `artifacts/${appId}/public/data/agents`);
     onSnapshot(agentsCol, (snapshot) => {
        const agents = [];
        snapshot.forEach((doc) => agents.push(doc.data()));

        agents.sort((a,b) => a.name.localeCompare(b.name));

        const container = document.getElementById('load-container');
        if (!container) return; // Exit if container not there

        let dropdownHTML = '';
        if(agents.length > 0) {
            dropdownHTML = `
                <div class="absolute right-0 mt-2 w-56 rounded-md shadow-lg bg-gray-700 ring-1 ring-black ring-opacity-5 z-10 hidden">
                  <div class="py-1" role="menu" aria-orientation="vertical" aria-labelledby="options-menu">
            `;
            agents.forEach(agent => {
                dropdownHTML += `
                    <div class="flex justify-between items-center px-4 py-2 text-sm text-[var(--text-secondary)] hover:bg-[var(--bg-interactive)] w-full text-left" role="menuitem">
                        <button class="flex-grow text-left load-agent-item" data-agent-name="${agent.name}">${agent.name}</button>
                        <div class="flex items-center">
                            <button class="manage-versions-btn text-[var(--text-tertiary)] hover:text-[var(--text-primary)] mr-3" data-agent-name="${agent.name}" title="Version History"><i class="fas fa-history"></i></button>
                            <button class="delete-agent-item text-[var(--text-tertiary)] hover:text-[var(--color-red-text)]" data-agent-name="${agent.name}" title="Delete Agent"><i class="fas fa-trash-alt"></i></button>
                        </div>
                    </div>
                `;
            });
            dropdownHTML += `</div></div>`;
        }

        container.innerHTML = `
            <button id="load-btn" class="bg-[var(--color-purple-action)] hover:bg-[var(--color-purple-action-hover)] text-[var(--text-primary)] font-bold py-2 px-4 rounded-md transition-colors shadow-lg ${agents.length === 0 ? 'opacity-50 cursor-not-allowed' : ''}" ${agents.length === 0 ? 'disabled' : ''}>
                <i class="fas fa-folder-open mr-2"></i>Load
            </button>
            ${dropdownHTML}
        `;

        const loadBtn = document.getElementById('load-btn');
        const dropdown = container.querySelector('.absolute');

        if (loadBtn && dropdown) {
            loadBtn.addEventListener('click', (e) => {
                e.stopPropagation();
                dropdown.classList.toggle('hidden');
            });

            document.addEventListener('click', (e) => {
                 if (container && !container.contains(e.target)) {
                    dropdown.classList.add('hidden');
                 }
            });

            container.querySelectorAll('.load-agent-item').forEach(item => {
                item.addEventListener('click', (e) => {
                    const button = e.currentTarget;
                    const originalText = button.innerHTML;
                    button.innerHTML = 'Loading...';
                    button.disabled = true;

                    loadAgent(button.dataset.agentName).finally(() => {
                        button.innerHTML = originalText;
                        button.disabled = false;
                    });
                });
            });

            container.querySelectorAll('.delete-agent-item').forEach(item => {
               item.addEventListener('click', (e) => {
                   e.stopPropagation();
                   deleteAgent(item.dataset.agentName);
               });
            });

            container.querySelectorAll('.manage-versions-btn').forEach(item => {
               item.addEventListener('click', (e) => {
                   e.stopPropagation();
                   openVersionsModal(item.dataset.agentName);
               });
            });
        }
    });
};

const openVersionsModal = async (agentName) => {
    const modal = document.getElementById('versions-modal');
    const title = document.getElementById('versions-modal-title');
    const container = document.getElementById('versions-list-container');

    title.textContent = `Version History for ${agentName}`;
    container.innerHTML = '<div class="text-center text-[var(--text-tertiary)]">Loading...</div>';
    openModal(modal);

    const agentRef = doc(db, `artifacts/${appId}/public/data/agents`, agentName);
    const versionsCol = collection(agentRef, 'versions');
    const versionsSnapshot = await getDocs(query(versionsCol, orderBy('createdAt', 'desc')));

    if (versionsSnapshot.empty) {
        container.innerHTML = '<div class="text-center text-[var(--text-tertiary)]">No versions found.</div>';
        return;
    }

    container.innerHTML = '';
    versionsSnapshot.forEach(doc => {
        const version = doc.data();
        const versionEl = document.createElement('div');
        versionEl.className = 'flex justify-between items-center p-2 bg-[var(--bg-tertiary)] rounded-md';
        versionEl.innerHTML = `
            <span class="text-sm text-[var(--text-secondary)]">Saved on: ${new Date(version.createdAt.seconds * 1000).toLocaleString()}</span>
            <button class="load-version-btn bg-[var(--color-blue-action)] hover:bg-[var(--color-blue-action-hover)] text-white text-xs font-bold py-1 px-2 rounded" data-version-id="${doc.id}">Load</button>
        `;
        container.appendChild(versionEl);
    });

    container.querySelectorAll('.load-version-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            loadAgent(agentName, btn.dataset.versionId);
            closeModal(modal);
        });
    });
};

// ---
// Button Creation & Main Action Listeners
// ---
// A wrapper for actions that modify the canvas to ensure history is saved.
const recordCanvasChange = (action) => {
    action(); // Perform the action
    const currentState = getAgentDataFromCanvas();
    historyManager.pushState(currentState);
};

const createMainButtons = () => {
    mainActionsContainer.innerHTML = `
        <div class="flex items-center space-x-1 bg-gray-700/50 rounded-md p-1">
            <button id="undo-btn" title="Undo (Ctrl+Z)" class="text-white font-bold py-1 px-3 rounded-md transition-colors hover:bg-gray-600 disabled:opacity-50 disabled:cursor-not-allowed"><i class="fas fa-undo"></i></button>
            <button id="redo-btn" title="Redo (Ctrl+Y)" class="text-white font-bold py-1 px-3 rounded-md transition-colors hover:bg-gray-600 disabled:opacity-50 disabled:cursor-not-allowed"><i class="fas fa-redo"></i></button>
        </div>
        <div class="h-6 w-px bg-gray-700"></div>
        <div id="file-menu-container" class="relative">
            <button id="file-menu-btn" class="bg-[var(--bg-interactive)] hover:bg-[var(--bg-interactive-hover)] text-[var(--text-primary)] font-bold py-2 px-4 rounded-md transition-colors shadow-lg"><i class="fas fa-file-alt mr-2"></i>File</button>
            <div id="file-menu-dropdown" class="absolute right-0 mt-2 w-56 rounded-md shadow-lg bg-[var(--bg-tertiary)] ring-1 ring-black ring-opacity-5 z-10 hidden">
                <div class="py-1" role="menu" aria-orientation="vertical">
                    <a href="#" id="import-btn" class="block px-4 py-2 text-sm text-[var(--text-secondary)] hover:bg-[var(--bg-interactive)]" role="menuitem"><i class="fas fa-file-import mr-2"></i>Import from JSON</a>
                    <a href="#" id="export-btn" class="block px-4 py-2 text-sm text-[var(--text-secondary)] hover:bg-[var(--bg-interactive)]" role="menuitem"><i class="fas fa-file-export mr-2"></i>Export to JSON</a>
                </div>
            </div>
        </div>
        <input type="file" id="import-file-input" class="hidden" accept=".json">

        <button id="save-btn" class="bg-[var(--color-blue-action)] hover:bg-[var(--color-blue-action-hover)] text-[var(--text-primary)] font-bold py-2 px-4 rounded-md transition-colors shadow-lg"><i class="fas fa-save mr-2"></i>Save (Cloud)</button>
        <div id="load-container" class="relative"></div> <!-- Container for load button and dropdown -->
        <button id="generate-btn" class="bg-[var(--color-green-action)] hover:bg-[var(--color-green-action-hover)] text-[var(--text-primary)] font-bold py-2 px-4 rounded-md transition-colors shadow-lg"><i class="fas fa-cogs mr-2"></i>Generate Prompt</button>
        <button id="clear-btn" class="bg-[var(--color-red-action)] hover:bg-[var(--color-red-action-hover)] text-[var(--text-primary)] font-bold py-2 px-4 rounded-md transition-colors shadow-lg"><i class="fas fa-trash mr-2"></i>Clear</button>
        <div class="h-6 w-px bg-[var(--border-primary)]"></div>
        <button id="help-btn" class="bg-[var(--bg-interactive)] hover:bg-[var(--bg-interactive-hover)] text-[var(--text-primary)] font-bold py-2 px-4 rounded-md transition-colors shadow-lg"><i class="fas fa-question-circle mr-2"></i>Help</button>
        <button id="theme-toggle-btn" class="bg-[var(--bg-interactive)] hover:bg-[var(--bg-interactive-hover)] text-[var(--text-primary)] font-bold py-2 px-3 rounded-md transition-colors shadow-lg"><i class="fas fa-sun"></i></button>
    `;
    // Re-assign listeners after creating them
    document.getElementById('save-btn').addEventListener('click', saveAgent);
    document.getElementById('generate-btn').addEventListener('click', generatePrompt);
    document.getElementById('help-btn').addEventListener('click', () => openModal(document.getElementById('help-modal')));

    const themeToggleBtn = document.getElementById('theme-toggle-btn');
    themeToggleBtn.addEventListener('click', () => {
        document.body.classList.toggle('light');
        const isLight = document.body.classList.contains('light');
        localStorage.setItem('theme', isLight ? 'light' : 'dark');
        themeToggleBtn.innerHTML = `<i class="fas ${isLight ? 'fa-moon' : 'fa-sun'}"></i>`;
    });

    document.getElementById('clear-btn').addEventListener('click', () => {
        showConfirm('Are you sure you want to clear the entire canvas? This action cannot be undone.', () => {
            recordCanvasChange(() => {
                canvas.innerHTML = '';
                updateCanvasPlaceholder();
            });
            showToast('Canvas cleared.', 'info');
        });
    });

    document.getElementById('undo-btn').addEventListener('click', () => {
        const prevState = historyManager.undo();
        if (prevState) {
            loadAgentDataToCanvas(prevState, false); // false to not record history
        }
    });

    document.getElementById('redo-btn').addEventListener('click', () => {
        const nextState = historyManager.redo();
        if (nextState) {
            loadAgentDataToCanvas(nextState, false); // false to not record history
        }
    });

    // --- File Menu Logic ---
    const fileMenuBtn = document.getElementById('file-menu-btn');
    const fileMenuDropdown = document.getElementById('file-menu-dropdown');
    const importBtn = document.getElementById('import-btn');
    const exportBtn = document.getElementById('export-btn');
    const importFileInput = document.getElementById('import-file-input');

    fileMenuBtn.addEventListener('click', (e) => {
        e.stopPropagation();
        fileMenuDropdown.classList.toggle('hidden');
    });

    document.addEventListener('click', () => {
        if (!fileMenuDropdown.classList.contains('hidden')) {
            fileMenuDropdown.classList.add('hidden');
        }
    });

    exportBtn.addEventListener('click', (e) => {
        e.preventDefault();
        const agentData = getAgentDataFromCanvas();
        if (agentData.length === 0) {
            showToast("Canvas is empty, nothing to export.", "error");
            return;
        }
        const jsonString = JSON.stringify(agentData, null, 2);
        const blob = new Blob([jsonString], { type: 'application/json' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = 'agent-config.json';
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        URL.revokeObjectURL(url);
        fileMenuDropdown.classList.add('hidden');
        showToast("Agent exported successfully!", "success");
    });

    importBtn.addEventListener('click', (e) => {
        e.preventDefault();
        importFileInput.click();
    });

    importFileInput.addEventListener('change', (e) => {
        const file = e.target.files[0];
        if (!file) return;

        const reader = new FileReader();
        reader.onload = (event) => {
            try {
                const data = JSON.parse(event.target.result);
                validateAgentData(data); // New validation step
                loadAgentDataToCanvas(data);
                showToast("Agent imported successfully!", "success");
            } catch (error) {
                console.error("Error importing file:", error);
                showToast(`Import failed: ${error.message}`, "error");
            } finally {
                // Reset file input to allow importing the same file again
                importFileInput.value = '';
                fileMenuDropdown.classList.add('hidden');
            }
        };
        reader.readAsText(file);
    });
}

const validateAgentData = (data) => {
    if (!Array.isArray(data)) {
        throw new Error("Invalid format: Data must be an array of blocks.");
    }
    for (const block of data) {
        if (typeof block !== 'object' || block === null) {
            throw new Error("Invalid block found: not an object.");
        }
        const requiredKeys = ['id', 'type', 'title', 'icon'];
        for (const key of requiredKeys) {
            if (!(key in block)) {
                throw new Error(`Invalid block found: missing required key '${key}'.`);
            }
        }
        if (block.type === 'group') {
            if ('blocks' in block && Array.isArray(block.blocks)) {
                validateAgentData(block.blocks); // Recursive validation
            } else {
                throw new Error("Invalid group block found: missing 'blocks' array.");
            }
        }
    }
    return true;
};


// ---
// Modal & Global Event Listeners
// ---
modalSaveBtn.addEventListener('click', saveModalChanges);
closeModalBtn.addEventListener('click', closeEditModal);
modalCancelBtn.addEventListener('click', closeEditModal);
editModalBackdrop.addEventListener('click', closeEditModal);

closePromptModalBtn.addEventListener('click', () => closeModal(promptModal));
promptDoneBtn.addEventListener('click', () => closeModal(promptModal));
promptModalBackdrop.addEventListener('click', () => closeModal(promptModal));

copyPromptBtn.addEventListener('click', () => {
    navigator.clipboard.writeText(promptOutput.textContent).then(() => {
        copyPromptBtn.innerHTML = '<i class="fas fa-check mr-1"></i> Copied!';
        setTimeout(() => {
            copyPromptBtn.innerHTML = '<i class="fas fa-copy mr-1"></i> Copy';
        }, 2000);
    }).catch(err => {
        console.error('Failed to copy text: ', err);
        // Fallback for older browsers
        const tempTextArea = document.createElement('textarea');
        tempTextArea.value = promptOutput.textContent;
        document.body.appendChild(tempTextArea);
        tempTextArea.select();
        document.execCommand('copy');
        document.body.removeChild(tempTextArea);
        copyPromptBtn.innerHTML = '<i class="fas fa-check mr-1"></i> Copied!';
        setTimeout(() => {
            copyPromptBtn.innerHTML = '<i class="fas fa-copy mr-1"></i> Copy';
        }, 2000);
    });
});

// --- Help Modal Logic ---
const guideContent = {
    title: "User Guide",
    sections: [
        {
            title: "Building Your Agent",
            content: "Drag component blocks from the toolbox on the left onto the canvas. Arrange them in the order you want the agent to process the instructions."
        },
        {
            title: "Editing Blocks",
            content: "Click the pencil icon (<i class='fas fa-pencil-alt'></i>) on any block to open the editor. Write your instructions in the text area and click 'Save Changes'."
        },
        {
            title: "Reordering & Deleting",
            content: "Click and drag any block on the canvas to reorder it. To remove a block, click the trash can icon (<i class='fas fa-trash-alt'></i>)."
        },
        {
            title: "Collapsing Blocks",
            content: "Click the chevron icon (<i class='fas fa-chevron-up'></i>) to collapse or expand a block. This is useful for managing long lists of instructions."
        },
        {
            title: "Undo & Redo",
            content: "Made a mistake? Use the Undo (<i class='fas fa-undo'></i>) and Redo (<i class='fas fa-redo'></i>) buttons to step backward or forward through your changes."
        },
        {
            title: "Saving & Loading",
            content: "<ul><li><b>Save (Cloud):</b> Saves your current configuration to your account online.</li><li><b>Load:</b> Loads a previously saved configuration from the cloud.</li><li><b>File Menu:</b> Use the 'File' menu to 'Export' your agent to a local JSON file or 'Import' one from your device. This is great for backups and sharing.</li></ul>"
        },
        {
            title: "Generating the Prompt",
            content: "When you're done, click 'Generate Prompt'. This compiles all your blocks into a single, structured prompt that you can copy and use."
        },
        {
            title: "Advanced Techniques",
            content: "<ul><li><b>Chain of Thought (CoT):</b> For complex reasoning tasks, add a rule like 'Think step-by-step before giving the final answer.' This encourages the AI to show its work, often leading to better results.</li><li><b>Few-Shot Prompting:</b> In a 'Persona' or 'Goal' block, provide 1-2 examples of the desired input/output format. This helps the AI understand exactly what you want.</li><li><b>Structured Output:</b> Use the 'Output Format' block to command the AI to return data in a specific structure like JSON or Markdown. This is essential for predictable, machine-readable results.</li></ul>"
        }
    ]
};

const examples = [
    {
        name: "Creative Writing Assistant",
        description: "A persona-driven assistant to help brainstorm story ideas.",
        data: [
            { id: "b1", type: "persona", title: "Persona / Role", icon: "fa-user-astronaut", content: "You are a world-class fiction author and creative partner. Your goal is to help the user build compelling stories by asking insightful questions and providing imaginative ideas. Your tone is encouraging and inspiring." },
            { id: "b2", type: "goal", title: "Primary Goal", icon: "fa-bullseye", content: "Help the user develop a high-concept idea for a science fiction novel. Brainstorm a protagonist, a core conflict, and a unique setting." },
            { id: "b3", type: "rule", title: "Strict Rule / Constraint", icon: "fa-gavel", content: "Do not write the story for the user. Only provide ideas, prompts, and guiding questions." },
            { id: "b4", type: "output", title: "Output Format", icon: "fa-code", content: "Provide your response as a markdown-formatted document with three sections: 'Protagonist Ideas', 'Conflict Scenarios', and 'Setting Concepts'." }
        ]
    },
    {
        name: "Code Review Bot",
        description: "An automated assistant that reviews code for common issues.",
        data: [
            { id: "c1", type: "persona", title: "Persona / Role", icon: "fa-user-astronaut", content: "You are an automated code review assistant. You are precise, and your feedback is constructive." },
            { id: "c2", type: "knowledge", title: "Knowledge Base", icon: "fa-book", content: "Your knowledge is based on the official documentation for Python, JavaScript, and general software engineering best practices for writing clean, maintainable code." },
            { id: "c3", type: "goal", title: "Primary Goal", icon: "fa-bullseye", content: "Review the provided code snippet. Identify potential bugs, style violations (based on PEP 8 for Python), and areas where readability could be improved. You must provide code examples for your suggestions." },
            { id: "c4", type: "output", title: "Output Format", icon: "fa-code", content: "Provide your review as a list of issues. Each issue should have a 'Severity' (High, Medium, Low), a 'Description', and a 'Suggested Fix' with a code example." }
        ]
    },
    {
        name: "Fact-Checking Bot (ReAct Style)",
        description: "A bot that uses a simplified Reason-Act loop to fact-check a statement.",
        data: [
            { id: "d1", type: "persona", title: "Persona / Role", icon: "fa-user-astronaut", content: "You are a meticulous fact-checking agent. You have access to a search tool. You must follow a strict reasoning process to verify statements." },
            { id: "d2", type: "goal", title: "Primary Goal", icon: "fa-bullseye", content: "Given a statement from the user, determine if it is true or false. You must use the provided search tool to find evidence." },
            { id: "d3", type: "tool", title: "Tools / Skills", icon: "fa-tools", content: "You have one tool: `search(query: string)`. You must use this tool to find relevant information." },
            { id: "d4", type: "rule", title: "Strict Rule / Constraint", icon: "fa-gavel", content: "You must follow the ReAct (Reason, Act, Observe) format. First, state your 'Reasoning' for what you need to find. Second, state the exact 'Action' you will take (e.g., `search('some query')`). Third, provide your final 'Answer' based on the observation (which you will imagine for this exercise)." },
            { id: "d5", type: "output", title: "Output Format", icon: "fa-code", content: "Your final output must be a single JSON object with two keys: `{\"answer\": \"True\" | \"False\" | \"Uncertain\", \"reasoning_steps\": [\"Your thought process here\"]}`" }
        ]
    }
];

const initHelpModal = () => {
    const guideContainer = document.getElementById('guide-content');
    guideContainer.innerHTML = `<h2 class="text-2xl font-bold text-white mb-6">${guideContent.title}</h2>` +
        guideContent.sections.map(s => `
            <div class="mb-6">
                <h3 class="text-lg font-semibold text-blue-400 mb-2">${s.title}</h3>
                <p class="text-gray-300 leading-relaxed">${s.content}</p>
            </div>
        `).join('');

    const examplesContainer = document.getElementById('examples-content');
    examplesContainer.innerHTML = `<h2 class="text-2xl font-bold text-white mb-6">Examples</h2>` +
        examples.map(e => `
            <div class="bg-gray-700/50 p-4 rounded-lg mb-4">
                <div class="flex justify-between items-center">
                    <div>
                        <h3 class="text-lg font-semibold text-green-400">${e.name}</h3>
                        <p class="text-sm text-gray-400">${e.description}</p>
                    </div>
                    <button class="load-example-btn bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded-md transition-colors" data-example-name="${e.name}">Load</button>
                </div>
            </div>
        `).join('');

    document.querySelectorAll('.load-example-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            const example = examples.find(e => e.name === btn.dataset.exampleName);
            if (example) {
                showConfirm("Loading an example will clear your current canvas. Are you sure?", () => {
                    loadAgentDataToCanvas(example.data);
                    closeModal(document.getElementById('help-modal'));
                    showToast(`Example '${example.name}' loaded!`, 'success');
                });
            }
        });
    });

    const helpTabs = document.querySelectorAll('.help-tab-btn');
    const helpContents = document.querySelectorAll('.help-tab-content');
    helpTabs.forEach(tab => {
        tab.addEventListener('click', () => {
            helpTabs.forEach(t => t.classList.remove('bg-blue-600/50', 'text-white'));
            tab.classList.add('bg-blue-600/50', 'text-white');

            helpContents.forEach(c => c.classList.add('hidden'));
            document.getElementById(`${tab.dataset.tab}-content`).classList.remove('hidden');
        });
    });

    document.getElementById('close-help-modal-btn').addEventListener('click', () => closeModal(document.getElementById('help-modal')));
};


const initToolboxTabs = () => {
    const tabButtons = document.querySelectorAll('.toolbox-tab-btn');
    const tabContents = document.querySelectorAll('.toolbox-tab-content');
    const variablesContainer = document.getElementById('variables-container');
    const addVariableBtn = document.getElementById('add-variable-btn');

    const setActiveTab = (tabName) => {
        tabButtons.forEach(btn => {
            const isActive = btn.dataset.tab === tabName;
            btn.classList.toggle('border-blue-500', isActive);
            btn.classList.toggle('text-white', isActive);
            btn.classList.toggle('border-transparent', !isActive);
            btn.classList.toggle('text-gray-400', !isActive);
            btn.classList.toggle('hover:border-blue-500', !isActive);
        });
        tabContents.forEach(content => {
            content.classList.toggle('hidden', content.id !== `${tabName}-tab-content`);
        });
    };

    tabButtons.forEach(btn => {
        btn.addEventListener('click', () => setActiveTab(btn.dataset.tab));
    });

    const createVariableRow = () => {
        const row = document.createElement('div');
        row.className = 'flex items-center space-x-2';
        row.innerHTML = `
            <input type="text" placeholder="key" class="variable-key w-1/3 bg-gray-900 border border-gray-600 rounded-md p-1 text-sm focus:ring-1 focus:ring-blue-500">
            <span class="text-gray-400">=</span>
            <input type="text" placeholder="value" class="variable-value flex-grow bg-gray-900 border border-gray-600 rounded-md p-1 text-sm focus:ring-1 focus:ring-blue-500">
            <button class="remove-variable-btn text-gray-500 hover:text-red-400 w-6 h-6 flex-shrink-0"><i class="fas fa-times"></i></button>
        `;
        row.querySelector('.remove-variable-btn').addEventListener('click', () => row.remove());
        variablesContainer.appendChild(row);
    };

    addVariableBtn.addEventListener('click', createVariableRow);

    // Set initial active tab
    setActiveTab('blocks');
    // Add one variable row to start
    createVariableRow();
};


// --- Command Palette Logic ---
const commands = [
    // Block creation commands
    { id: 'cmd-persona', title: 'Create: Persona / Role Block', icon: 'fa-user-astronaut', action: () => document.querySelector('.toolbox-item[data-type="persona"]').click() },
    { id: 'cmd-goal', title: 'Create: Primary Goal Block', icon: 'fa-bullseye', action: () => document.querySelector('.toolbox-item[data-type="goal"]').click() },
    { id: 'cmd-knowledge', title: 'Create: Knowledge Base Block', icon: 'fa-book', action: () => document.querySelector('.toolbox-item[data-type="knowledge"]').click() },
    { id: 'cmd-tools', title: 'Create: Tools / Skills Block', icon: 'fa-tools', action: () => document.querySelector('.toolbox-item[data-type="tool"]').click() },
    { id: 'cmd-rule', title: 'Create: Strict Rule Block', icon: 'fa-gavel', action: () => document.querySelector('.toolbox-item[data-type="rule"]').click() },
    { id: 'cmd-output', title: 'Create: Output Format Block', icon: 'fa-code', action: () => document.querySelector('.toolbox-item[data-type="output"]').click() },
    { id: 'cmd-group', title: 'Create: Group Block', icon: 'fa-object-group', action: () => document.querySelector('.toolbox-item[data-type="group"]').click() },
    // Action commands
    { id: 'cmd-save', title: 'Save to Cloud', icon: 'fa-save', action: saveAgent },
    { id: 'cmd-generate', title: 'Generate Prompt', icon: 'fa-cogs', action: generatePrompt },
    { id: 'cmd-clear', title: 'Clear Canvas', icon: 'fa-trash', action: () => document.getElementById('clear-btn').click() },
    { id: 'cmd-export', title: 'Export to JSON', icon: 'fa-file-export', action: () => document.getElementById('export-btn').click() },
    { id: 'cmd-import', title: 'Import from JSON', icon: 'fa-file-import', action: () => document.getElementById('import-btn').click() },
    { id: 'cmd-help', title: 'Open Help & Examples', icon: 'fa-question-circle', action: () => document.getElementById('help-btn').click() },
    { id: 'cmd-undo', title: 'Undo', icon: 'fa-undo', action: () => document.getElementById('undo-btn').click() },
    { id: 'cmd-redo', title: 'Redo', icon: 'fa-redo', action: () => document.getElementById('redo-btn').click() },
];

const initCommandPalette = () => {
    const modal = document.getElementById('command-palette-modal');
    const input = document.getElementById('command-palette-input');
    const resultsContainer = document.getElementById('command-palette-results');
    let activeIndex = -1;

    const openPalette = () => {
        renderResults('');
        openModal(modal);
        input.focus();
    };

    const closePalette = () => {
        closeModal(modal);
        input.value = '';
        activeIndex = -1;
    };

    const renderResults = (searchTerm) => {
        resultsContainer.innerHTML = '';
        const filteredCommands = commands.filter(cmd => cmd.title.toLowerCase().includes(searchTerm.toLowerCase()));

        filteredCommands.forEach((cmd, index) => {
            const resultEl = document.createElement('div');
            resultEl.className = 'p-2 rounded-md hover:bg-gray-700 cursor-pointer flex items-center';
            resultEl.innerHTML = `<i class="fas ${cmd.icon} w-8 text-center text-gray-400"></i><span>${cmd.title}</span>`;
            resultEl.addEventListener('click', () => {
                cmd.action();
                closePalette();
            });
            resultsContainer.appendChild(resultEl);
        });
        activeIndex = -1;
        updateActiveResult();
    };

    const updateActiveResult = () => {
        const results = resultsContainer.children;
        for (let i = 0; i < results.length; i++) {
            results[i].classList.toggle('bg-blue-600/50', i === activeIndex);
        }
    };

    const executeActiveResult = () => {
        if (activeIndex > -1) {
            const activeResult = resultsContainer.children[activeIndex];
            activeResult.click();
        }
    };

    window.addEventListener('keydown', (e) => {
        if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
            e.preventDefault();
            openPalette();
        }
    });

    input.addEventListener('keydown', (e) => {
        const results = resultsContainer.children;
        if (e.key === 'ArrowDown') {
            e.preventDefault();
            activeIndex = (activeIndex + 1) % results.length;
            updateActiveResult();
        } else if (e.key === 'ArrowUp') {
            e.preventDefault();
            activeIndex = (activeIndex - 1 + results.length) % results.length;
            updateActiveResult();
        } else if (e.key === 'Enter') {
            e.preventDefault();
            executeActiveResult();
        } else if (e.key === 'Escape') {
            closePalette();
        }
    });

    input.addEventListener('input', () => renderResults(input.value));
    document.getElementById('command-palette-backdrop').addEventListener('click', closePalette);
};


// --- Playground Logic ---
const initPlayground = () => {
    const playgroundBtn = document.getElementById('playground-btn');
    const playgroundModal = document.getElementById('playground-modal');
    const closePlaygroundBtn = document.getElementById('close-playground-modal-btn');
    const apiKeyInput = document.getElementById('api-key-input');
    const modelSelect = document.getElementById('model-select');
    const temperatureSlider = document.getElementById('temperature-slider');
    const temperatureValue = document.getElementById('temperature-value');
    const chatArea = document.getElementById('playground-chat-area');
    const playgroundInput = document.getElementById('playground-input');
    const sendBtn = document.getElementById('playground-send-btn');

    let conversationHistory = [];
    let systemPrompt = '';

    apiKeyInput.value = sessionStorage.getItem('gemini-api-key') || '';
    apiKeyInput.addEventListener('input', () => sessionStorage.setItem('gemini-api-key', apiKeyInput.value));
    temperatureSlider.addEventListener('input', () => temperatureValue.textContent = temperatureSlider.value);

    playgroundBtn.addEventListener('click', () => {
        systemPrompt = document.getElementById('prompt-output').textContent;
        conversationHistory = [];
        chatArea.innerHTML = '<div class="text-center text-[var(--text-tertiary)]">Playground session started. The generated prompt is now active as the system instruction.</div>';
        closeModal(document.getElementById('prompt-modal'));
        openModal(playgroundModal);
        playgroundInput.focus();
    });

    closePlaygroundBtn.addEventListener('click', () => closeModal(playgroundModal));

    const addMessageToChat = (role, text, isStreaming = false) => {
        const roleClass = role === 'user' ? 'bg-blue-600/30 self-end' : 'bg-[var(--bg-tertiary)] self-start';
        const roleName = role === 'user' ? 'You' : 'Agent';

        if (isStreaming) {
            let lastMessage = chatArea.querySelector('.streaming-message');
            if (!lastMessage) {
                lastMessage = document.createElement('div');
                lastMessage.className = `p-3 rounded-lg max-w-xl streaming-message ${roleClass}`;
                lastMessage.innerHTML = `<div class="font-bold mb-1">${roleName}</div><p></p>`;
                chatArea.appendChild(lastMessage);
            }
            lastMessage.querySelector('p').innerHTML += text.replace(/\n/g, '<br>');
        } else {
            const streamingMessage = chatArea.querySelector('.streaming-message');
            if(streamingMessage) streamingMessage.classList.remove('streaming-message');

            const messageEl = document.createElement('div');
            messageEl.className = `p-3 rounded-lg max-w-xl ${roleClass}`;
            messageEl.innerHTML = `<div class="font-bold mb-1">${roleName}</div><p>${text.replace(/\n/g, '<br>')}</p>`;
            chatArea.appendChild(messageEl);
        }
        chatArea.scrollTop = chatArea.scrollHeight;
    };

    const sendMessage = async () => {
        const userInput = playgroundInput.value.trim();
        if (!userInput) return;

        const apiKey = apiKeyInput.value.trim();
        if (!apiKey) {
            showToast("Please enter your Gemini API key.", "error");
            return;
        }

        addMessageToChat('user', userInput);
        conversationHistory.push({ role: "user", parts: [{ text: userInput }] });
        playgroundInput.value = '';
        sendBtn.disabled = true;

        const model = modelSelect.value;
        const temperature = parseFloat(temperatureSlider.value);
        const apiEndpoint = `https://generativelanguage.googleapis.com/v1beta/models/${model}:streamGenerateContent?key=${apiKey}&alt=sse`;

        const requestBody = {
            contents: conversationHistory.slice(0, -1), // Send history up to the last user message
            system_instruction: { parts: [{ text: systemPrompt }] },
            generationConfig: { temperature: temperature }
        };

        try {
            const response = await fetch(apiEndpoint, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(requestBody)
            });

            if (!response.ok) {
                const errorText = await response.text();
                throw new Error(JSON.parse(errorText).error.message || `HTTP error! status: ${response.status}`);
            }

            const reader = response.body.getReader();
            const decoder = new TextDecoder();
            let fullResponse = "";

            while (true) {
                const { value, done } = await reader.read();
                if (done) break;

                const chunk = decoder.decode(value);
                const lines = chunk.split('\n');
                for (const line of lines) {
                    if (line.startsWith('data: ')) {
                        const jsonStr = line.substring(6);
                        try {
                            const data = JSON.parse(jsonStr);
                            const text = data.candidates[0].content.parts[0].text;
                            fullResponse += text;
                            addMessageToChat('model', text, true);
                        } catch (e) {
                            // Ignore parsing errors for incomplete JSON chunks
                        }
                    }
                }
            }
            conversationHistory.push({ role: "model", parts: [{ text: fullResponse }] });

        } catch (error) {
            console.error("API Error:", error);
            showToast(`API Error: ${error.message}`, "error");
            addMessageToChat('model', `Sorry, I encountered an error: ${error.message}`);
        } finally {
            const streamingMessage = chatArea.querySelector('.streaming-message');
            if(streamingMessage) streamingMessage.classList.remove('streaming-message');
            sendBtn.disabled = false;
            playgroundInput.focus();
        }
    };

    sendBtn.addEventListener('click', sendMessage);
    playgroundInput.addEventListener('keydown', (e) => {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            sendMessage();
        }
    });
    playgroundInput.addEventListener('input', () => autoResizeTextarea(playgroundInput));
};

// --- Suggestion Logic ---
const suggestionState = {
    suggestion: '',
    isLoading: false,
};

const debounce = (func, delay) => {
    let timeout;
    return (...args) => {
        clearTimeout(timeout);
        timeout = setTimeout(() => func.apply(this, args), delay);
    };
};

const getSuggestion = async (text) => {
    const apiKey = document.getElementById('api-key-input').value.trim();
    if (!apiKey) return null; // No key, no suggestion
    if (text.trim().split(' ').length < 5) return null; // Don't bother for very short text

    suggestionState.isLoading = true;

    const metaPrompt = `You are an expert prompt engineer. A user is writing an instruction for an AI agent. Your task is to make the instruction more precise, detailed, and effective. Return ONLY the improved text, without any preamble, explanation, or quotation marks.

Original instruction: "${text}"

Improved instruction:`;

    const apiEndpoint = `https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=${apiKey}`;
    const requestBody = { contents: [{ parts: [{ text: metaPrompt }] }] };

    try {
        const response = await fetch(apiEndpoint, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(requestBody)
        });
        if (!response.ok) return null;
        const data = await response.json();
        return data.candidates[0].content.parts[0].text.trim();
    } catch (error) {
        console.error("Suggestion API Error:", error);
        return null;
    } finally {
        suggestionState.isLoading = false;
    }
};

const updateSuggestionUI = (suggestion) => {
    const suggestionBtn = document.getElementById('suggestion-btn');
    const suggestionPopover = document.getElementById('suggestion-popover');
    const suggestionText = document.getElementById('suggestion-text');

    if (suggestion) {
        suggestionState.suggestion = suggestion;
        suggestionText.textContent = suggestion;
        suggestionBtn.classList.remove('hidden');
    } else {
        suggestionBtn.classList.add('hidden');
        suggestionPopover.classList.add('hidden');
    }
};


// --- Initial Call ---
const applySavedTheme = () => {
    const savedTheme = localStorage.getItem('theme');
    const themeToggleBtn = document.getElementById('theme-toggle-btn');
    if (savedTheme === 'light') {
        document.body.classList.add('light');
        if(themeToggleBtn) themeToggleBtn.innerHTML = `<i class="fas fa-moon"></i>`;
    } else {
        if(themeToggleBtn) themeToggleBtn.innerHTML = `<i class="fas fa-sun"></i>`;
    }
};

createMainButtons();
applySavedTheme();
updateCanvasPlaceholder();
initDragAndDrop(); // Initialize the new drag and drop system
historyManager.init(getAgentDataFromCanvas()); // Set initial state for undo/redo
initHelpModal();
initToolboxTabs();
initCommandPalette();
initPlayground();
// Initial call to setup listener is handled by onAuthStateChanged
