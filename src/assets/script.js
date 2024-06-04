// Function to delete script elements with src="/.11ty/reload-client.js"
///This is here to help with local 11nty dev

function deleteReloadClientScripts() {
  document.querySelectorAll('script[src="/.11ty/reload-client.js"]').forEach(function (item) {
    item.remove();
  });
}

// Function to save the DOM as an HTML file
function saveDOMAsHTML() {
  // Turn off editing so we don't lock it on
  turnOffAllTextEditable();

  // Turn off all draggable elements
  turnOffDraggableElements();

  // Call the function to delete the script elements
  deleteReloadClientScripts();

  // Get the current title and make it filesafe
  const fileSafeTitle = () =>
    document.title
      .replace(/[^\w\s]/g, "")
      .trim()
      .replace(/\s+/g, "-");
  const htmlContent = document.documentElement.outerHTML;

  // Create a Blob with the HTML content
  const blob = new Blob([htmlContent], { type: "text/html" });

  // Create a temporary URL to the Blob
  const url = URL.createObjectURL(blob);

  // Create a link element to trigger the download
  const a = document.createElement("a");
  a.href = url;
  a.download = fileSafeTitle() + ".html";

  // Trigger a click event on the link to start the download
  a.click();

  // Clean up by revoking the Blob URL
  URL.revokeObjectURL(url);
}

let isEditable = false;

function turnOffAllTextEditable() {
  const textNodes = getTextNodes(document);
  textNodes.forEach((node) => {
    node.parentElement.removeAttribute("contentEditable");
  });
  isEditable = false;
  // set text of anchor #edit to "Stop Editing" to reflect state
  document.getElementById("edit").innerText = "Edit";
}

function toggleAllTextEditable() {
  const textNodes = getTextNodes(document);
  isEditable = !isEditable;
  // set text of anchor #edit to "Edit" or "Stop Editing" to reflect state
  textNodes.forEach((node) => {
    node.parentElement.contentEditable = isEditable;
  });
  document.getElementById("edit").innerText = isEditable ? "Stop Editing" : "Edit";
}
function getTextNodes(element) {
  const textNodes = [];
  function extractTextNodes(node) {
    if (node.nodeType === Node.TEXT_NODE) {
      textNodes.push(node);
    } else {
      for (const childNode of node.childNodes) {
        extractTextNodes(childNode);
      }
    }
  }
  extractTextNodes(element);
  return textNodes;
}

document.body.addEventListener("paste", function (e) {
  e.preventDefault();

  // Get the pasted text
  const clipboardData = e.clipboardData || window.clipboardData;
  const pastedText = clipboardData.getData("text/plain");

  // Filter out properties that don't start with "--"
  const filteredText = pastedText.replace(/(--[\w-]+:[^;]+;)/g, "");

  // Insert the filtered text into the body's contentEditable
  document.execCommand("insertText", false, filteredText);
});

// Define a debounce function
function debounce(func, wait) {
  let timeout;
  return function (...args) {
    clearTimeout(timeout);
    timeout = setTimeout(() => func.apply(this, args), wait);
  };
}

// Drag and Drop
var isDragMode = false;
var draggedElement = null;
var placeholder = document.createElement("section");
var lastTarget = null;

placeholder.style.border = "3px dashed #0099FF"; // Placeholder styling
placeholder.style.height = "1px"; // Set a default height, adjust as needed
// set a negative margin to compensate for the additional height
placeholder.style.marginBottom = "-0.2rem";
placeholder.style.display = "block";

function toggleDraggableElements() {
  isDragMode = !isDragMode;
  var elementsToToggle = document.querySelectorAll(
    "img, p, ol, ul, li, blockquote, h1, h2, h3, h4, h5, h6, pre, code, a, em, strong, div, article, summary, details, nav, aside, span, script, style"
  );
  elementsToToggle.forEach(function (element) {
    element.setAttribute("draggable", isDragMode);
  });
}

function turnOffDraggableElements() {
  isDragMode = false;
  // set text of anchor #toggleDrag to "Drag" to reflect state
  document.getElementById("toggleDrag").innerText = "Drag";
  //remove .removeAttribute('draggable') for any elements that have it
  // select by attribute
  var elementsToToggle = document.querySelectorAll("[draggable]");
  elementsToToggle.forEach(function (element) {
    element.removeAttribute("draggable");
  });
}

function handleDragStart(event) {
  if (!isDragMode) {
    event.preventDefault();
    return;
  }
  draggedElement = event.target;
}

function handleDragOver(event) {
  if (!isDragMode || !draggedElement) {
    event.preventDefault();
    return;
  }
  event.preventDefault();
  var dropTarget = event.target;

  // Get the previous sibling of the drop target
  var previousSibling = dropTarget.previousElementSibling;

  // Only move the placeholder if it's not already in the correct position
  if (previousSibling !== placeholder) {
    dropTarget.insertAdjacentElement("beforebegin", placeholder);
  }
}

function handleDrop(event) {
  if (!isDragMode || !draggedElement) {
    event.preventDefault();
    return;
  }
  event.preventDefault();

  requestAnimationFrame(() => {
    placeholder.replaceWith(draggedElement);
    draggedElement = null; // Reset the draggedElement variable
  });
}

function handleMouseOver(event) {
  if (isDragMode) {
    //event.target.style.outline = '2px solid #0099FF';  Blue outline
  }
}

function handleMouseOut(event) {
  if (isDragMode) {
    event.target.style.outline = ""; // Remove outline
  }
}

var toggleDragButton = document.getElementById("toggleDrag");
toggleDragButton.addEventListener("click", function () {
  toggleDraggableElements();
  toggleDragButton.textContent = isDragMode ? "Stop Drag" : "Drag";
});

document.addEventListener("dragstart", handleDragStart);
document.addEventListener("dragover", handleDragOver);
document.addEventListener("drop", handleDrop);
document.addEventListener("mouseover", handleMouseOver);
document.addEventListener("mouseout", handleMouseOut);

// Add a listener for the "dblclick" event
document.addEventListener("dblclick", function (event) {
  var target = event.target;
  var style = target.getAttribute("style");
  var prompt = document.getElementById("prompt");
  prompt.value = style;

  // open prompt_wrapper
  var promptWrapper = document.getElementById("prompt_wrapper");
  promptWrapper.style.display = "block";

  // focus on prompt
  prompt.focus();

  // add a listener for the "input" event
  prompt.addEventListener("input", function (event) {
    var newStyle = prompt.value;

    if (newStyle) {
      target.setAttribute("style", newStyle);
    } else {
      target.removeAttribute("style");
    }
  });
  // Intercept the "submit" event and hide the prompt_wrapper
  promptWrapper.addEventListener("submit", function (event) {
    event.preventDefault();
    promptWrapper.style.display = "none";
    target = "none";
  });
  // tear down and clean up make sure that the next double click doesn't
  // use the same newStyle
  prompt.addEventListener("blur", function (event) {
    promptWrapper.style.display = "none";
    target = "none";
  });
});


//if (window.location.hostname === "localhost") {
// We'll do it if we're on a file:// URL
if (window.location.protocol === "file:") {
  var edit_bar = document.getElementById("edit_bar");
  edit_bar.style.setProperty("--d", "block"); // Use setProperty to modify CSS variables
  edit_bar.addEventListener("click", function () {
    toggleAllTextEditable();
  });
}
