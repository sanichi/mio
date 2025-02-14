import { Controller } from "@hotwired/stimulus"
import { Elm } from "elm_weight"

export default class extends Controller {
  static targets = [ "elm" ]

  static values = {
    start: Number,
    units: String,
    kilos: Array,
    dates: Array,
    debug: Boolean,
  }

  connect() {
    window.weight_app = Elm.Weight.init({
      node: this.elmTarget,
      flags: {
        start: this.startValue,
        units: this.unitsValue,
        kilos: this.kilosValue,
        dates: this.datesValue,
        debug: this.debugValue,
      }
    });

    document.getElementById("weight").addEventListener("click", (e) => {
      const pt = e.target.createSVGPoint();
      pt.x = e.clientX;
      pt.y = e.clientY;
      const qt = pt.matrixTransform(e.target.getScreenCTM().inverse());
      weight_app.ports.changeCross.send([Math.round(qt.x), Math.round(qt.y)]);
    });
  }

  changeStart(e) {
    weight_app.ports.changeStart.send(parseInt(e.target.value));
  }

  changeUnits(e) {
    weight_app.ports.changeUnits.send(e.target.value);
  }

  moveCross(e) {
    const d = e.shiftKey ? 10 : 1
    switch (e.keyCode) {
      case 72: // h
      case 37: // left arrow
        weight_app.ports.updateCross.send([-d,0]);
        break;
      case 76: // l
      case 39: // right arrow
        weight_app.ports.updateCross.send([d,0]);
        break;
      case 74: // j
      case 40: // down arrow
        e.preventDefault(); // otherwise down arrow may scroll page
        weight_app.ports.updateCross.send([0,-d]);
        break;
      case 75: // k
      case 38: // up arrow
        e.preventDefault(); // otherwise up arrow may scroll page
        weight_app.ports.updateCross.send([0,d]);
        break;
    }
  }

  disconnect() {
    delete window.weight_app
  }
}
