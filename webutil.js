// click all expand commit message in github commits
(() => {
    document.querySelectorAll('button[data-testid="commit-row-show-description-button"]').forEach((btn) => {
        btn.click();
    });
})();

// click all expand your chat button on Google AI
(() => {
    document.querySelectorAll('div[role="button"].l1LGWd').forEach((el) => {
        el.click();
    });
})();

// click next image button on Google images
const next = () => document.querySelector('button[aria-label="Next image"]')?.click();
// click previous image button on Google images
const prev = () => document.querySelector('button[aria-label="Previous image"]')?.click();
