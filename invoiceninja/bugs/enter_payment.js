// BEGIN isConditionMet
const isConditionMet = () => {
    // Only on the saved payment's page (the dashboard also has select values and grey badges)
    const onPayment = /^\/payments\/[A-Za-z0-9]+\/edit$/.test(window.location.pathname);

    // Check if the Payment Type singleValue exists
    const paymentTypeExists = !!document.querySelector('.css-ood9ll-singleValue');

    // Check if the Unapplied badge exists
    const unappliedExists = Array.from(
        document.querySelectorAll('span.text-xs.px-2.py-1.rounded.bg-gray-500.text-white')
    ).some(s => s.textContent.trim() === 'Unapplied');

    // Only trigger if all hold
    return onPayment && paymentTypeExists && unappliedExists;
};
// END isConditionMet

// BEGIN onConditionMet
const onConditionMet = () => {
    // Select the div that shows the currently selected Payment Type
    const displayDiv = document.querySelector('.css-ood9ll-singleValue');

    // Change its text to "Visa"
    if (displayDiv) {
        displayDiv.textContent = "Visa";
    }
};
// END onConditionMet
