import { Controller } from "@hotwired/stimulus"
import "jquery"
import "autocomplete"

export default class extends Controller {
  static values = {
    personId: Number,
  }

  connect() {
    console.log(this.personIdValue);
    const controller = this;
    $(this.element).autocomplete({
      source: "/people/match.json",
      minLength: 2,
      select: function(event, ui) {
        if (ui.item) {
          Turbo.visit("/people/" + controller.personIdValue + "/relationship?other=" + ui.item.id, { acceptsStreamResponse: true });
        }
        setTimeout(function() {
          controller.element.value = "";
        }, 200);
        return false;
      }
    });
  }
}

