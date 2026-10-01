// BEGIN isConditionMet
const isConditionMet = () => {
    // Only care about this exact page
    const header = document.querySelector("h1.title")
    const active = header && header.offsetParent !== null && header.textContent.trim() === "Products";
    return window.__BUG_INJECTOR_API__.transition("prestashop_seller_view_catalog_product_details", {
        active,
        after: 2,
    });
};
// END isConditionMet

// BEGIN onConditionMet
const onConditionMet = () => {
    const tbody = document.querySelector("tbody");
    if (!tbody) return;

    const rows = tbody.querySelectorAll("tr");
    if (rows.length === 0) return;

    // Remove the last row
    const lastRow = rows[rows.length - 1];
    lastRow.remove();
};
// END onConditionMet
