import { Controller } from "@hotwired/stimulus"
import { Elm } from "elm_play"

export default class extends Controller {
  connect() {
    const app = Elm.Main.init({
      node: this.element,
      flags: {
        current_year: new Date().getFullYear(),
      },
    });
    app.ports.random_request.subscribe(function () {
      const answer = Math.floor((Math.random() * 8 + 1));
      app.ports.random_response.send(answer);
    });
  }
}
