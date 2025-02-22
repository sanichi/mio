import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "delta" ]

  static values = {
    id: Number,
  }

  go(e) {
    const data = {
      direction: e.params.d,
      type: e.params.t,
      delta: this.deltaTarget.value
    };
    $.ajax({
      url: "/places/" + this.idValue + "/shift",
      type: "patch",
      data: data,
      dataType: "html"
    }).done(function(data) {
      $('#map').html(data);
    });
  }
}
