// BEGIN isConditionMet
const isConditionMet = () => {
    // Check path and panels existence
    const condition = window.location.pathname === "/";
    return window.__BUG_INJECTOR_API__.transition("prestashop_buyer_view_new_product_details", {
        active: condition,
        after: 2,
    });
};
// END isConditionMet

// BEGIN onConditionMet
const onConditionMet = () => {
    document.querySelectorAll('section.featured-products').forEach(section => {
        const title = section.querySelector('h2');
        if (title && title.textContent.trim() === 'On sale') {
            section.remove();
        }
    });
};
// END onConditionMet
