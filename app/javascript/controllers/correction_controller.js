import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    date: String,
    days: String,
    ulid: String,
  }

  connect() {
    if (this.hasDateValue) document.getElementById("date").value = this.dateValue;
    if (this.hasDaysValue) document.getElementById("days").value = this.daysValue;
    if (this.hasUlidValue) document.getElementById("upload_id").value = this.ulidValue;
  }
}
