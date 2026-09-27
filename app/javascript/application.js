import "popper"
import "bootstrap"
import "@hotwired/turbo-rails"
import "controllers"

Turbo.config.drive.progressBarDelay = 200;

// Close any open dropdowns (e.g. the nav search menus) before Turbo snapshots the page,
// otherwise they come back stuck open when returning via the browser's back button.
document.addEventListener("turbo:before-cache", () => {
  document.querySelectorAll('[data-bs-toggle="dropdown"].show').forEach(el => {
    bootstrap.Dropdown.getOrCreateInstance(el).hide();
  });
});
