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
    this.app.ports.displayPerson.subscribe((id) => {
      Turbo.visit(`/people/${id}`);
    });
    const controller = this;
    this.app.ports.getFocus.subscribe((id) => {
      controller.getFocus(id);
    });
  }

  getFocus(id) {
    if (Number(id) === id && id % 1 === 0 && id > 0) {
      const controller = this;
      fetch(`/people/tree.json?id=${id}`)
        .then(response => {
          if (!response.ok) throw new Error("response error:", response.status);
          return response.json();
        })
        .then(data => {
          controller.gotFocus(data);
        })
        .catch(error => {
          console.error("focus fetch error:", error);
        });
    } else {
      console.log("invalid person id:", id);
    }
  }

  gotFocus(data) {
    this.app.ports.gotFocus.send(data);
  }
}
