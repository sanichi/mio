import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "single" ]

  singleTargetConnected(element) {
    const href = element.href;
    setTimeout(() => {
      Turbo.visit(href, { action: "replace" });
    }, 500);
  }
}
