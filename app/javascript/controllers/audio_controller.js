import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "button" ]

  static values = {
    rid: Number,
    count: Number,
    index: Number,
  }

  say() {
    this.element.querySelector("#audio_" + this.ridValue + "_" + this.indexValue).play();

    // Cycle round the other audios.
    this.indexValue += 1;
    if (this.indexValue >= this.countValue) this.indexValue = 0;

    // Prepare to accept keyboatd input incase of accent updates.
    this.buttonTarget.focus();
  }

  update(e) {
    const code = e.keyCode;
    let accent = "";
    if (code == 189) { // - (meaning tried but couldn't find out)
      accent = "-";
    } else if (code == 191) { // ? (meaning not yet known)
      accent = "?";
    } else if (code >= 48 && code <= 57) { // 0-9
      accent = (code - 48).toString();
    } else if (code >= 65 && code <= 71) { // a-j or A-J which we use to signal 10-16 (note the longest WK reading is 11)
      accent = (code - 55).toString();
    }
    if (accent.length == 1 || accent.length == 2) {
      const button = this.buttonTarget;
      const rid = this.ridValue;
      const url = "/wk/readings/" + rid + "/quick_accent_update";
      const options = {
        method: "PATCH",
        headers: {
          "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content,
          "Content-type": "application/json; charset=UTF-8",
        },
        body: JSON.stringify({
          accent: accent,
        }),
      };
      fetch(url, options)
        .then(response => {
          if (!response.ok) throw new Error("response error:", response.status);
          return response.json();
        })
        .then(data => {
          button.innerText = data.accent_display;
          const classes = button.classList;
          data.pattern_colours.forEach((colour) => {
            classes.remove("btn-" + colour);
          });
          classes.add("btn-" + data.pattern_colour);
        })
        .catch(error => {
          console.error("fetch error:", error);
        });
      }
  };
}
