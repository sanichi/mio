import { Controller } from "@hotwired/stimulus"
import { Elm } from "elm_petrol"

export default class extends Controller {
  static targets = [ "elm", "beginMenu" ]

  static values = {
    debug: Boolean,
    stationNames: Array,
    stationColours: Array,
    stations: Array,
    dates: Array,
    prices: Array,
  }

  app = null

  connect() {
    // Elm replaces this node, taking the target attribute with it, so it has
    // to be read before initialising and the click listener hung on the
    // controller's own element afterwards.
    const node = this.elmTarget;

    this.app = Elm.Petrol.init({
      node: node,
      flags: {
        begin: parseInt(this.beginMenuTarget.value),
        debug: this.debugValue,
        stationNames: this.stationNamesValue,
        stationColours: this.stationColoursValue,
        stations: this.stationsValue,
        dates: this.datesValue,
        prices: this.pricesValue,
      }
    });

    this.element.addEventListener("click", e => {
      const svg = e.target.closest("svg");
      if (svg) {
        const pt = svg.createSVGPoint();
        pt.x = e.clientX;
        pt.y = e.clientY;
        const qt = pt.matrixTransform(svg.getScreenCTM().inverse());
        this.app.ports.changeCross.send([Math.round(qt.x), Math.round(qt.y)]);
      }
    });
  }

  changeBegin(e) {
    this.app.ports.changeBegin.send(parseInt(e.target.value));
  }

  moveCross(e) {
    if (e.target instanceof HTMLInputElement) return; // don't hijack the legend's tick boxes
    const d = e.shiftKey ? 10 : 1
    switch (e.keyCode) {
      case 72: // h
      case 37: // left arrow
        this.app.ports.updateCross.send([-d,0]);
        break;
      case 76: // l
      case 39: // right arrow
        this.app.ports.updateCross.send([d,0]);
        break;
      case 74: // j
      case 40: // down arrow
        e.preventDefault(); // otherwise down arrow may scroll page
        this.app.ports.updateCross.send([0,1]);
        break;
      case 75: // k
      case 38: // up arrow
        e.preventDefault(); // otherwise up arrow may scroll page
        this.app.ports.updateCross.send([0,-1]);
        break;
    }
  }
}
