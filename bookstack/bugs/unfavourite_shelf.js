// BEGIN isConditionMet
const isConditionMet = () => {
  const heading = document.querySelector('h1.list-heading');
  return heading && heading.textContent.trim() === 'My Favourites';
};
// END isConditionMet

// BEGIN onConditionMet
const onConditionMet = () => {
  // Unfavouriting 'Shelf' also drops another favourite: the list no longer
  // equals the previous list minus 'Shelf'.
  const entityList = document.querySelector('main .book-contents .entity-list');
  if (!entityList) return;
  const item = Array.from(entityList.querySelectorAll('.entity-list-item'))
    .find(el => el.querySelector('.entity-list-item-name')?.textContent.trim() === 'Chapter 2');
  if (item) item.remove();
};
// END onConditionMet