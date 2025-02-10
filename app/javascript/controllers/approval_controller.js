import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { tid: Number }

  toggle() {
    const url = "/transactions/" + this.tidValue + "/quick_approval_update";
    const options = {
      method: "PATCH",
      headers: {
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content,
      },
    };
    const element = this.element;
    fetch(url, options)
      .then(response => {
        if (!response.ok) throw new Error("response error:", response.status);
        return response.json();
      })
      .then(data => {
        element.innerText = data.text;
      })
      .catch(error => {
        console.error("fetch error:", error);
      });
  }
}
