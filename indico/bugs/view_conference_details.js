// BEGIN isConditionMet
const isConditionMet = () => {
    const TARGET_PATH = "/";

    // Check path
    const pathOk = window.location.pathname === TARGET_PATH;

    // Check for header existence
    const headerExists = Array.from(document.querySelectorAll("h4")).some(h => {
        const span = h.querySelector("span");
        return span && span.textContent.trim() === "January 2025";
    });

    // Current condition
    const condition = pathOk && headerExists;
    return window.__BUG_INJECTOR_API__.transition("indico_view_conference_details", {
        active: condition,
        after: 2,
    });
};
// END isConditionMet

// BEGIN onConditionMet
const onConditionMet = () => {
    // Find the <h4> containing "January 2025"
    const header = Array.from(document.querySelectorAll("h4")).find(h => {
        const span = h.querySelector("span");
        return span && span.textContent.trim() === "January 2025";
    });

    if (header) {
        // Get the <ul> immediately following the <h4>
        const ul = header.nextElementSibling;
        
        if (ul && ul.tagName === "UL") {
            const items = ul.querySelectorAll("li");
            if (items.length > 0) {
                // Remove the middle event
                const middleIndex = Math.floor(items.length / 2);
                items[middleIndex].remove();
                console.log("Middle event removed!");
            } else {
                console.warn("No events found in the list.");
            }
        } else {
            console.warn("No <ul> found after the header.");
        }
    } else {
        console.warn("Header for January 2025 not found.");
    }
};
// END onConditionMet
