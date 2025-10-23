import { initializeApp } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-app.js";
import { getAuth, signInAnonymously, signInWithCustomToken, onAuthStateChanged } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-auth.js";
import { getFirestore, doc, setDoc, getDoc, collection, onSnapshot, deleteDoc } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-firestore.js";

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
const mobileMenuBtn = document.getElementById('mobile-menu-btn');
const toolbox = document.getElementById('toolbox');
const closeToolboxBtn = document.getElementById('close-toolbox-btn');
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

const generateBtn = document.getElementById('generate-btn');
const clearBtn = document.getElementById('clear-btn');
const saveBtn = document.getElementById('save-btn');
const loadContainer = document.getElementById('load-container');

let currentEditingBlock = null;

// --- Custom Modal Functions ---
const showAlert = (message, title = 'Alert') => {
    alertModalTitle.textContent = title;
    alertModalMessage.textContent = message;
    alertModal.style.display = 'block';
    alertModalBackdrop.style.display = 'block';

    return new Promise((resolve) => {
        alertModalOkBtn.onclick = () => {
            alertModal.style.display = 'none';
            alertModalBackdrop.style.display = 'none';
            resolve();
        };
        closeAlertModalBtn.onclick = () => {
            alertModal.style.display = 'none';
            alertModalBackdrop.style.display = 'none';
            resolve();
        };
    });
};

const showConfirm = (message, title = 'Confirmation') => {
    confirmModalTitle.textContent = title;
    confirmModalMessage.textContent = message;
    confirmModal.style.display = 'block';
    confirmModalBackdrop.style.display = 'block';

    return new Promise((resolve) => {
        confirmModalConfirmBtn.onclick = () => {
            confirmModal.style.display = 'none';
            confirmModalBackdrop.style.display = 'none';
            resolve(true);
        };
        confirmModalCancelBtn.onclick = () => {
            confirmModal.style.display = 'none';
            confirmModalBackdrop.style.display = 'none';
            resolve(false);
        };
        closeConfirmModalBtn.onclick = () => {
            confirmModal.style.display = 'none';
            confirmModalBackdrop.style.display = 'none';
            resolve(false);
_        };
    });
};

const showPrompt = (message, title = 'Input Required', defaultValue = '') => {
    inputPromptModalTitle.textContent = title;
    inputPromptModalMessage.textContent = message;
    inputPromptModalInput.value = defaultValue;
    inputPromptModal.style.display = 'block';
    inputPromptModalBackdrop.style.display = 'block';
    setTimeout(() => inputPromptModalInput.focus(), 50);

    return new Promise((resolve) => {
        inputPromptModalSaveBtn.onclick = () => {
            inputPromptModal.style.display = 'none';
            inputPromptModalBackdrop.style.display = 'none';
            resolve(inputPromptModalInput.value);
        };
        inputPromptModalCancelBtn.onclick = () => {
            inputPromptModal.style.display = 'none';
            inputPromptModalBackdrop.style.display = 'none';
            resolve(null);
        };
        closeInputPromptModalBtn.onclick = () => {
            inputPromptModal.style.display = 'none';
            inputPromptModalBackdrop.style.display = 'none';
            resolve(null);
        };
    });
};

// --- Custom Modal Elements ---
// Alert Modal
const alertModalBackdrop = document.getElementById('alert-modal-backdrop');
const alertModal = document.getElementById('alert-modal');
const alertModalTitle = document.getElementById('alert-modal-title');
const alertModalMessage = document.getElementById('alert-modal-message');
const closeAlertModalBtn = document.getElementById('close-alert-modal-btn');
const alertModalOkBtn = document.getElementById('alert-modal-ok-btn');

// Confirm Modal
const confirmModalBackdrop = document.getElementById('confirm-modal-backdrop');
const confirmModal = document.getElementById('confirm-modal');
const confirmModalTitle = document.getElementById('confirm-modal-title');
const confirmModalMessage = document.getElementById('confirm-modal-message');
const closeConfirmModalBtn = document.getElementById('close-confirm-modal-btn');
const confirmModalCancelBtn = document.getElementById('confirm-modal-cancel-btn');
const confirmModalConfirmBtn = document.getElementById('confirm-modal-confirm-btn');

// Input Prompt Modal
const inputPromptModalBackdrop = document.getElementById('input-prompt-modal-backdrop');
const inputPromptModal = document.getElementById('input-prompt-modal');
const inputPromptModalTitle = document.getElementById('input-prompt-modal-title');
const inputPromptModalMessage = document.getElementById('input-prompt-modal-message');
const closeInputPromptModalBtn = document.getElementById('close-input-prompt-modal-btn');
const inputPromptModalInput = document.getElementById('input-prompt-modal-input');
const inputPromptModalCancelBtn = document.getElementById('input-prompt-modal-cancel-btn');
const inputPromptModalSaveBtn = document.getElementById('input-prompt-modal-save-btn');

// --- Core Functions ---
const updateCanvasPlaceholder = () => {
    const hasItems = canvas.querySelector('.canvas-item');
    canvasPlaceholder.style.display = hasItems ? 'none' : 'flex';
};

const createBlockElement = (blockData) => {
    const { id, type, title, icon, content } = blockData;

    const div = document.createElement('div');
    div.className = `canvas-item bg-gray-800/80 border border-gray-700 rounded-lg p-4 shadow-lg flex items-start space-x-4`;
    div.dataset.id = id;
    div.dataset.type = type;
    div.dataset.title = title;
    div.dataset.icon = icon;
    div.draggable = true;

    div.innerHTML = `
        <i class="fas ${icon} text-xl text-gray-400 pt-1"></i>
        <div class="flex-1">
            <h3 class="font-bold text-white">${title}</h3>
            <p class="content-preview text-sm text-gray-300 mt-1">${content || 'Click to configure...'}</p>
        </div>
        <div class="flex flex-col space-y-2">
            <button class="edit-btn text-gray-400 hover:text-blue-400 transition-colors"><i class="fas fa-pencil-alt"></i></button>
            <button class="delete-btn text-gray-400 hover:text-red-400 transition-colors"><i class="fas fa-trash-alt"></i></button>
        </div>
    `;
    // Store content in a data attribute for easy access
    div.dataset.content = content || '';

    // Attach event listeners to the new block
    div.querySelector('.edit-btn').addEventListener('click', () => openEditModal(div));
    div.querySelector('.delete-btn').addEventListener('click', () => {
        div.remove();
        updateCanvasPlaceholder();
    });
    return div;
};

const openEditModal = (blockElement) => {
    currentEditingBlock = blockElement;
    modalTitle.innerHTML = `<i class="fas ${blockElement.dataset.icon} mr-2"></i> Configure ${blockElement.dataset.title}`;
    modalTextarea.value = blockElement.dataset.content || '';
    modalTextarea.placeholder = blockElement.dataset.placeholder || 'Enter your instructions here...';
    editModal.style.display = 'block';
    editModalBackdrop.style.display = 'block';
    setTimeout(() => modalTextarea.focus(), 50);
};

const closeEditModal = () => {
    editModal.style.display = 'none';
    editModalBackdrop.style.display = 'none';
    currentEditingBlock = null;
};

const saveModalChanges = () => {
    if (currentEditingBlock) {
        const newContent = modalTextarea.value;
        currentEditingBlock.dataset.content = newContent;
        const preview = currentEditingBlock.querySelector('.content-preview');
        preview.textContent = newContent || 'Click to configure...';
        if (!newContent) {
           preview.classList.add('text-gray-500');
        } else {
           preview.classList.remove('text-gray-500');
        }
    }
    closeEditModal();
};

const generatePrompt = () => {
    const blocks = canvas.querySelectorAll('.canvas-item');
    if (blocks.length === 0) {
        showAlert("Canvas is empty! Add some blocks to generate a prompt.", "Empty Canvas");
        return;
    }
    let promptText = "### AGENT CONFIGURATION ###\n\n";
    blocks.forEach(block => {
        const title = block.dataset.title.toUpperCase();
        const content = block.dataset.content || 'Not configured.';
        promptText += `## ${title} ##\n${content}\n\n`;
    });
    promptOutput.textContent = promptText.trim();
    promptModal.style.display = 'block';
    promptModalBackdrop.style.display = 'block';
};

// --- Drag and Drop Logic (with SortableJS) ---
// Initialize SortableJS for the toolbox
const toolboxSortable = new Sortable(document.querySelector('#toolbox .space-y-3'), {
    group: {
        name: 'shared',
        pull: 'clone',
        put: false // Do not allow items to be dropped into the toolbox
    },
    animation: 150,
    sort: false, // Do not sort items in the toolbox
    ghostClass: 'dragging-ghost',
});

// Initialize SortableJS for the canvas
const canvasSortable = new Sortable(canvas, {
    group: 'shared',
    animation: 150,
    ghostClass: 'dragging-ghost',
    onAdd: function (evt) {
        const itemEl = evt.item; // The dragged element from the toolbox
        const blockData = {
            id: `block-${Date.now()}`,
            type: itemEl.dataset.type,
            title: itemEl.dataset.title,
            icon: itemEl.dataset.icon,
            content: ''
        };
        const newBlock = createBlockElement(blockData);

        // Replace the clone with the new, fully functional block
        evt.from.insertBefore(itemEl, evt.item.nextSibling); // put the original back
        canvas.replaceChild(newBlock, itemEl);

        updateCanvasPlaceholder();
    }
});

// --- Firestore Persistence ---
const getAgentDataFromCanvas = () => {
    const blocks = [];
    canvas.querySelectorAll('.canvas-item').forEach(el => {
        blocks.push({
            id: el.dataset.id,
            type: el.dataset.type,
            title: el.dataset.title,
            icon: el.dataset.icon,
            content: el.dataset.content
        });
    });
    return blocks;
};

const loadAgentDataToCanvas = (agentData) => {
    canvas.innerHTML = ''; // Clear canvas
    if (agentData && agentData.length > 0) {
        agentData.forEach(blockData => {
            const newBlock = createBlockElement(blockData);
            canvas.appendChild(newBlock);
        });
    }
    updateCanvasPlaceholder();
};

const saveAgent = async () => {
    if (!userId) {
        showAlert("User not authenticated. Please wait.", "Authentication Error");
        return;
    }
    const agentName = await showPrompt("Enter a name for this agent configuration:", "Save Agent");
    if (!agentName) return;

    const agentData = getAgentDataFromCanvas();
    const docRef = doc(db, `artifacts/${appId}/public/data/agents`, agentName);
    try {
        await setDoc(docRef, { name: agentName, data: agentData, createdAt: new Date() });
        showAlert(`Agent '${agentName}' saved successfully!`, "Save Successful");
    } catch (error) {
        console.error("Error saving agent:", error);
        showAlert("Failed to save agent.", "Save Error");
    }
};

const loadAgent = async (agentName) => {
    if (!userId) {
        showAlert("User not authenticated. Please wait.", "Authentication Error");
        return;
    }
    const docRef = doc(db, `artifacts/${appId}/public/data/agents`, agentName);
    try {
        const docSnap = await getDoc(docRef);
        if (docSnap.exists()) {
            const agent = docSnap.data();
            loadAgentDataToCanvas(agent.data);
            showAlert(`Agent '${agentName}' loaded.`, "Load Successful");
        } else {
            showAlert("Agent not found.", "Load Error");
        }
    } catch (error) {
        console.error("Error loading agent:", error);
        showAlert("Failed to load agent.", "Load Error");
    }
};

const deleteAgent = async (agentName, dropdown, button) => {
     if (!userId) {
        showAlert("User not authenticated. Please wait.", "Authentication Error");
        return;
    }
    if (!await showConfirm(`Are you sure you want to delete the agent '${agentName}'? This cannot be undone.`, "Delete Agent")) {
        return;
    }
    const docRef = doc(db, `artifacts/${appId}/public/data/agents`, agentName);
     try {
        await deleteDoc(docRef);
        showAlert(`Agent '${agentName}' deleted.`, "Delete Successful");
        // The onSnapshot listener will automatically update the UI
    } catch(e) {
        console.error("Error deleting agent: ", e);
        showAlert("Failed to delete agent.", "Delete Error");
    }
}

const setupRealtimeListener = () => {
     if (!userId) return;
     const agentsCol = collection(db, `artifacts/${appId}/public/data/agents`);
     onSnapshot(agentsCol, (snapshot) => {
        const agents = [];
        snapshot.forEach((doc) => agents.push(doc.data()));

        // Sort agents by name for consistent order
        agents.sort((a,b) => a.name.localeCompare(b.name));

        let dropdownHTML = '';
        if(agents.length > 0) {
            dropdownHTML = `
                <div class="absolute right-0 mt-2 w-56 rounded-md shadow-lg bg-gray-700 ring-1 ring-black ring-opacity-5 z-10 hidden">
                  <div class="py-1" role="menu" aria-orientation="vertical" aria-labelledby="options-menu">
            `;
            agents.forEach(agent => {
                dropdownHTML += `
                    <div class="flex justify-between items-center px-4 py-2 text-sm text-gray-200 hover:bg-gray-600 w-full text-left" role="menuitem">
                        <button class="flex-grow text-left load-agent-item" data-agent-name="${agent.name}">${agent.name}</button>
                        <button class="delete-agent-item text-gray-400 hover:text-red-400" data-agent-name="${agent.name}"><i class="fas fa-trash-alt"></i></button>
                    </div>
                `;
            });
            dropdownHTML += `</div></div>`;
        }

        loadContainer.innerHTML = `
            <button id="load-btn" class="bg-purple-600 hover:bg-purple-700 text-white font-bold py-2 px-4 rounded-md transition-colors shadow-lg ${agents.length === 0 ? 'opacity-50 cursor-not-allowed' : ''}" ${agents.length === 0 ? 'disabled' : ''}>
                <i class="fas fa-folder-open mr-2"></i>Load
            </button>
            ${dropdownHTML}
        `;

        const loadBtn = document.getElementById('load-btn');
        const dropdown = loadContainer.querySelector('.absolute');

        if (loadBtn && dropdown) {
            loadBtn.addEventListener('click', (e) => {
                e.stopPropagation();
                dropdown.classList.toggle('hidden');
            });

            document.addEventListener('click', () => dropdown.classList.add('hidden'));

            loadContainer.querySelectorAll('.load-agent-item').forEach(item => {
                item.addEventListener('click', () => loadAgent(item.dataset.agentName));
            });

            loadContainer.querySelectorAll('.delete-agent-item').forEach(item => {
               item.addEventListener('click', (e) => {
                   e.stopPropagation(); // prevent dropdown from closing
                   deleteAgent(item.dataset.agentName, dropdown, item);
               });
           });
        }
    });
};

// --- Event Listeners ---
clearBtn.addEventListener('click', async () => {
    if (await showConfirm('Are you sure you want to clear the entire canvas?', 'Clear Canvas')) {
        canvas.innerHTML = '';
        updateCanvasPlaceholder();
    }
});

saveBtn.addEventListener('click', saveAgent);

modalSaveBtn.addEventListener('click', saveModalChanges);
closeModalBtn.addEventListener('click', closeEditModal);
modalCancelBtn.addEventListener('click', closeEditModal);
editModalBackdrop.addEventListener('click', closeEditModal);

generateBtn.addEventListener('click', generatePrompt);
closePromptModalBtn.addEventListener('click', () => {
    promptModal.style.display = 'none';
    promptModalBackdrop.style.display = 'none';
});
promptDoneBtn.addEventListener('click', () => {
     promptModal.style.display = 'none';
     promptModalBackdrop.style.display = 'none';
});
promptModalBackdrop.addEventListener('click', () => {
     promptModal.style.display = 'none';
     promptModalBackdrop.style.display = 'none';
});

copyPromptBtn.addEventListener('click', () => {
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

// --- Event Listeners for Mobile Nav ---
if (mobileMenuBtn && toolbox && closeToolboxBtn) {
    mobileMenuBtn.addEventListener('click', () => {
        toolbox.classList.remove('-translate-x-full');
    });

    closeToolboxBtn.addEventListener('click', () => {
        toolbox.classList.add('-translate-x-full');
    });
}

// --- Initial Call ---
updateCanvasPlaceholder();
