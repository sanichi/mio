import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    ftob: Object,
    btof: Object,
    okay: Boolean,
  }

  mouseEnter(e) {
    if (this.okayValue) {
      if (e.target.id.startsWith("bay")) {
        this.highlight(e.target, undefined, true);
      } else {
        this.highlight(undefined, e.target, true);
      }
    }
  }

  mouseLeave(e) {
    if (this.okayValue) {
      if (e.target.id.startsWith("bay")) {
        this.highlight(e.target, undefined, false);
      } else {
        this.highlight(undefined, e.target, false);
      }
    }
  }

  highlight(bay, flat, on) {
    if (bay) {
      flat = document.getElementById(this.btofValue[bay.id]);
    } else {
      bay = document.getElementById(this.ftobValue[flat.id]);
    }
    if (on) {
      bay.classList.add("focus");
      flat.classList.add("focus");
    } else {
      bay.classList.remove("focus");
      flat.classList.remove("focus");
    }
  }
}
