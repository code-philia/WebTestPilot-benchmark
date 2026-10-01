// BEGIN isConditionMet
const isConditionMet = () => {
  // Check path and panels existence
  const condition = window.location.pathname === "/module/blockwishlist/view" && window.location.search.includes("id_wishlist=1");
  return window.__BUG_INJECTOR_API__.transition("prestashop_buyer_add_product_to_wishlist", {
      active: condition,
      after: 2,
  });
};
// END isConditionMet

// BEGIN onConditionMet
const onConditionMet = () => {
    const list = document.querySelector("ul.wishlist-products-list");

    if (list && list.lastElementChild) {
        list.lastElementChild.remove();
    }
};
// END onConditionMet
