// Blocks marked `data-reveal` rise into place the first time they scroll into
// view. The value is the delay in seconds, so a row of cards can stagger.
//
// The `js` class on <html> is what lets the stylesheet hide them up front: it
// is set here, so a visitor without JavaScript never gets an invisible page.
export function revealOnScroll() {
  document.documentElement.classList.add('js');

  const show = (element: HTMLElement) => {
    element.style.setProperty('--reveal-delay', (element.dataset.reveal || '0') + 's');
    element.dataset.revealed = '';
  };

  const pending = () =>
    document.querySelectorAll<HTMLElement>('[data-reveal]:not([data-revealed])');

  if (typeof IntersectionObserver === 'undefined') {
    pending().forEach(show);
    return;
  }

  const observer = new IntersectionObserver(
    (entries) => {
      for (const entry of entries) {
        if (!entry.isIntersecting) continue;
        show(entry.target as HTMLElement);
        observer.unobserve(entry.target);
      }
    },
    { rootMargin: '0px 0px -6% 0px', threshold: 0.06 },
  );
  pending().forEach((element) => observer.observe(element));

  // A block that is already on screen when a tab is restored can miss the
  // observer's first pass; sweep the fold once as a safety net.
  setTimeout(() => {
    pending().forEach((element) => {
      if (element.getBoundingClientRect().top < window.innerHeight * 1.2) show(element);
    });
  }, 1200);
}
