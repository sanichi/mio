import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    source: String,
    target: String,
  }

  connect() {
    const controller = this;
    $(this.element).autocomplete({
      source: this.sourceValue,
      minLength: 2,
      select: function(event, ui) {
        if (ui.item) {
          document.getElementById(controller.targetValue).value = ui.item ? ui.item.id : "";
        }
        setTimeout(function() {
          controller.element.value = "";
        }, 200);
      }
    });
  }
}

