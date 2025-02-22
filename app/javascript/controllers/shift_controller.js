import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "delta" ]

  static values = {
    id: Number,
  }

  go(e) {
    const url = "/places/" + this.idValue + "/shift";
    const options = {
      method: "PATCH",
      headers: {
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content,
        "Content-type": "application/json; charset=UTF-8",
      },
      body: JSON.stringify({
        direction: e.params.d,
        type: e.params.t,
        delta: this.deltaTarget.value,
      }),
    };
    fetch(url, options)
      .then(response => {
        if (!response.ok) throw new Error("response error:", response.status);
        return response.text();
      })
      .then(html => {
        document.getElementById("map").innerHTML = html;
      })
      .catch(error => {
        console.error("fetch error:", error);
      });
  }
}
