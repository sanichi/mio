import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  clicked(e) {
    if (e.params.place) {
      Turbo.visit("/places/" + e.params.place);
    } else {
      Turbo.visit("/prefectures");
    }
  }
}
