import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Adapted from https://getbootstrap.com/docs/5.3/components/tooltips/#overview
    const els = document.querySelectorAll('[data-bs-toggle="tooltip"]');
    [...els].map(el => new bootstrap.Tooltip(el));
  }
}
