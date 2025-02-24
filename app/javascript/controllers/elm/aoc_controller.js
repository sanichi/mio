import { Controller } from "@hotwired/stimulus"
import { Elm } from "elm_aoc"

export default class extends Controller {
  connect() {
    const app = Elm.Main.init({
      node: this.element,
      flags: {
        year: "2021",
        day: "1"
      }
    });
    app.ports.getData.subscribe((yd) => {
      fetch(`/aoc/${yd[0]}/${yd[1]}.txt`)
        .then(response => {
          if (!response.ok) throw new Error("response error:", response.status);
          return response.text();
        })
        .then(data => {
          app.ports.gotData.send(data);
        })
        .catch(error => {
          console.error("getData fetch error:", error);
        });
    });
    app.ports.getRuby.subscribe((ydp) => {
      fetch(`/ruby?year=${ydp[0]}&day=${ydp[1]}&part=${ydp[2]}`)
        .then(response => {
          if (!response.ok) throw new Error("response error:", response.status);
          return response.text();
        })
        .then(data => {
          app.ports.gotRuby.send([ydp[2], data]);
        })
        .catch(error => {
          console.error("getRuby fetch error:", error);
        });
    });
    app.ports.doPause.subscribe((part) => {
      // this timeout is here so elm will pause long enough to display
      // the "thinking" gif before it starts calculating the answer
      setTimeout(() => {
        app.ports.donePause.send(part);
      }, 100);
    });
  }
}
