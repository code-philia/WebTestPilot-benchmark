// BEGIN isConditionMet
const isConditionMet = () => {
    return window.__BUG_INJECTOR_API__.transition("invoiceninja_delete_expired_quote", {
        active: window.location.pathname === "/dashboard",
        after: 2,
    });
};
// END isConditionMet

// BEGIN onConditionMet
const onConditionMet = () => {
    // --- Editable data variables ---
    const number = "123456_expired";
    const client = "company_name";
    const date = "Jan 01";
    const amount = "$ 60,000.00";

    // --- 1. Identify the table under "Upcoming Quotes" ---
    const tables = document.querySelectorAll("form table");
    let upcomingQuotesTable = null;

    tables.forEach(table => {
    const heading = table.closest("form")?.querySelector("h3 span");
    if (heading && heading.textContent.trim() === "Expired Quotes") {
        upcomingQuotesTable = table;
    }
    });

    if (!upcomingQuotesTable) {
        console.error("Upcoming Quotes table not found!");
    } else {
        // --- 2. Get the tbody and clear all rows ---
        const tbody = upcomingQuotesTable.querySelector("tbody");
        tbody.innerHTML = "";

        // --- 3. Insert a new row ---
        const newRow = document.createElement("tr");
        newRow.className = "border-b border-gray-200";
        newRow.style.borderColor = "rgb(209, 213, 219)";

        newRow.innerHTML = `
            <td class="px-2 py-2 text-sm break-words cursor-pointer overflow-hidden whitespace-nowrap text-ellipsis first:pl-2">
            <a href="/quotes/${number}/edit" class="text-sm hover:underline" style="color: rgb(17, 125, 192);">${number}</a>
            </td>
            <td class="px-2 py-2 text-sm break-words cursor-pointer overflow-hidden whitespace-nowrap text-ellipsis first:pl-2">
            <a href="/clients/${client}" class="text-sm hover:underline" style="color: rgb(17, 125, 192);">${client}</a>
            </td>
            <td class="px-2 py-2 text-sm break-words cursor-pointer overflow-hidden whitespace-nowrap text-ellipsis first:pl-2">
            ${date}
            </td>
            <td class="px-2 py-2 text-sm break-words overflow-hidden whitespace-nowrap text-ellipsis first:pl-2">
            <span class="text-xs px-2 py-1 rounded bg-blue-300 text-white font-mono">${amount}</span>
            </td>
        `;

        tbody.appendChild(newRow);
    }
};
// END onConditionMet
