import "popper"
import "bootstrap"
import "@hotwired/turbo-rails"
import "controllers"

Turbo.config.drive.progressBarDelay = 200;

// Close any open dropdowns (e.g. the nav search menus) and remove any showing tooltips or
// popovers before Turbo snapshots the page, otherwise they come back stuck open when
// returning via the browser's back button.
document.addEventListener("turbo:before-cache", () => {
  document.querySelectorAll('[data-bs-toggle="dropdown"].show').forEach(el => {
    bootstrap.Dropdown.getOrCreateInstance(el).hide();
  });
  document.querySelectorAll('[data-bs-toggle="tooltip"]').forEach(el => {
    bootstrap.Tooltip.getInstance(el)?.dispose();
  });
  document.querySelectorAll('[data-bs-toggle="popover"]').forEach(el => {
    bootstrap.Popover.getInstance(el)?.dispose();
  });
});
