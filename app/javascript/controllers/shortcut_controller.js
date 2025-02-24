import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "single" ]

  singleTargetConnected(element) {
    element.removeAttribute("data-shortcut-target");
    const href = element.href;
    setTimeout(() => {
      Turbo.visit(href);
    }, 500);
  }
}
