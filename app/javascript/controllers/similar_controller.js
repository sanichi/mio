import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    message: String,
    query: String,
  }

  connect() {
    document.getElementById("message").innerText = this.messageValue;
    document.getElementById("query").value = this.queryValue;
  }
}
