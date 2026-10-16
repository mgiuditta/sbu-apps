// A page reached by a view transition keeps the full stop that flew in: without this class the stamp
// starts over when the transition ends, and the square vanishes and drops a second time.
addEventListener('pagereveal', (e) => { if (e.viewTransition) document.documentElement.classList.add('flown'); });
