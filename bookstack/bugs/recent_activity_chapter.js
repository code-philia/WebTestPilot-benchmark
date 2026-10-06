// BEGIN isConditionMet
const isConditionMet = () => {
  // A chapter page with its Details block (chapter pages have no Recent Activity list).
  const onChapter = /^\/books\/[^/]+\/chapter\/[^/]+\/?$/.test(window.location.pathname);
  const details = Array.from(document.querySelectorAll('h5'))
    .some(h => h.textContent.trim() === 'Details');
  return onChapter && details && !!document.querySelector('.entity-meta');
};
// END isConditionMet

// BEGIN onConditionMet
const onConditionMet = () => {
  const timestampSpans = document.querySelectorAll('.entity-meta span');

  timestampSpans.forEach(span => {
    const text = span.textContent;

    // Match ONLY "N hour ago" or "N hours ago"
    const match = text.match(/\b(\d+)\s+(second|minute|hour|day)s?\s+ago\b/i);

    if (match) {
      // Replace only the matched phrase
      const updated = text.replace(match[0], '2 days ago');
      span.textContent = updated;

      // Update tooltip if present
      if (span.hasAttribute('title')) {
        const titleText = span.getAttribute('title');
        const updatedTitle = titleText.replace(/\b\d+\s+hours?\s+ago\b/, '2 days ago');
        span.setAttribute('title', updatedTitle);
      }
    }
  });

  console.log("All hour-based timestamps updated!");
};
// END onConditionMet