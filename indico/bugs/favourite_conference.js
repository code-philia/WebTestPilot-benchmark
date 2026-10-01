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
    return window.__BUG_INJECTOR_API__.transition("indico_favourite_conference", {
        active: condition,
        after: 2,
    });
};
// END isConditionMet

// BEGIN onConditionMet
const onConditionMet = () => {
    const tryHeader = () => {
        const header = Array.from(document.querySelectorAll("h4")).find(h => {
            const span = h.querySelector("span");
            return span && span.textContent.trim() === "January 2025";
        });

        if (!header) {
            setTimeout(tryHeader, 200);
            return;
        }

        const ul = header.nextElementSibling;
        if (!ul || ul.tagName !== "UL") return;

        const items = ul.querySelectorAll("li");
        if (items.length === 0) return;

        // Pick the middle event
        const middleIndex = Math.floor(items.length / 2);
        const eventItem = items[middleIndex];

        // ⭐ Inject star
        const iconsSpan = eventItem.querySelector(".event-icons");
        if (!iconsSpan) return;

        if (!iconsSpan.querySelector(".icon-star")) {
            const starIcon = document.createElement("i");
            starIcon.className = "icon-star";
            starIcon.setAttribute(
                "data-qtip-oldtitle",
                "You have favorited this event."
            );
            iconsSpan.appendChild(starIcon);
        }

        const eventTitleLink = eventItem.querySelector(".event-title a");
        if (eventTitleLink) {
            eventTitleLink.style.color = "red";
            eventTitleLink.style.fontWeight = "bold"; // optional but nice
        }
    };

    tryHeader();
};
// END onConditionMet
