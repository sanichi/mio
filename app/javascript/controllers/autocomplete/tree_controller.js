import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static outlets = [ "elm--tree" ]

  static values = {
    source: String,
  }

  connect() {
    const controller = this;
    $(this.element).autocomplete({
      source: this.sourceValue,
      minLength: 2,
      select: function(event, ui) {
        if (ui.item) {
          controller.elmTreeOutlet.getFocus(ui.item.id);
        }
        $(this).val("");
        return false;
      }
    });
  }
}

