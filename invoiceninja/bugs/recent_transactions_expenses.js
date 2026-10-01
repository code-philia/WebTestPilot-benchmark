// BEGIN isConditionMet
const isConditionMet = () => {
    return window.__BUG_INJECTOR_API__.transition("invoiceninja_recent_transactions_expenses", {
        active: window.location.pathname === "/dashboard",
        after: 2,
    });
};
// END isConditionMet

// BEGIN onConditionMet
const onConditionMet = () => {
    // Find the outer container with the label "Outstanding"
    const container = [...document.querySelectorAll('div.flex.justify-between.items-center')].find(div => {
        const label = div.querySelector('span.text-gray-500');
        return label && label.textContent.trim() === "Outstanding";
    });

    if (container) {
        // Find the span with the amount
        const amountSpan = container.querySelector('span.text-base.font-mono');
        if (amountSpan) {
            amountSpan.textContent = "$ 100,000.00";
            console.log("Amount updated!");
        }
    }

    // Find the container with the label "Total Invoices Outstanding"
    const container2 = [...document.querySelectorAll('div.flex.justify-between.items-center')].find(div => {
        const label = div.querySelector('span.text-gray-500');
        return label && label.textContent.trim() === "Total Invoices Outstanding";
    });

    if (container2) {
        // Find the span that contains the number
        const numberSpan = container2.querySelector('span.text-base.font-mono');
        if (numberSpan) {
            numberSpan.textContent = "2";
            console.log("Total Invoices Outstanding updated!");
        }
    }
};
// END onConditionMet
