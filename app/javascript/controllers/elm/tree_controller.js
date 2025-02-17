import { Controller } from "@hotwired/stimulus"
import { Elm } from "elm_tree"

export default class extends Controller {
  static targets = [ "elm" ]

  static values = {
    focus: Object,
  }

  app = null

  connect() {
    this.app = Elm.Main.init({
      node: this.elmTarget,
      flags: { focus: this.focusValue }
    });
    this.app.ports.displayPerson.subscribe(function(id) {
      window.location.href = "/people/" + id; // TODO: revisit this after turbo is opt-out
    });
    const controller = this;
    this.app.ports.getFocus.subscribe(function(id) {
      controller.getFocus(id);
    });
  }

  getFocus(id) {
    if (Number(id) === id && id % 1 === 0 && id > 0) {
      const controller = this;
      $.ajax({
        url: "/people/tree.json?id=" + id
      }).done(function(focus) {
        controller.gotFocus(focus);
      });
    }
  }

  gotFocus(focus) {
    this.app.ports.gotFocus.send(focus);
  }
}
