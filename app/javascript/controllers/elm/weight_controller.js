import { Controller } from "@hotwired/stimulus"
import { Elm } from "elm_weight"

export default class extends Controller {
  static targets = [ "elm", "beginMenu", "endMenu", "unitsMenu" ]

  static values = {
    kilos: Array,
    dates: Array,
    debug: Boolean,
    eventNames: Array,
    eventDates: Array,
    eventSpans: Array,
  }

  app = null

  connect() {
    this.app = Elm.Weight.init({
      node: this.elmTarget,
      flags: {
        begin: parseInt(this.beginMenuTarget.value),
        end: parseInt(this.endMenuTarget.value),
        units: this.unitsMenuTarget.value,
        kilos: this.kilosValue,
        dates: this.datesValue,
        debug: this.debugValue,
        eventNames: this.eventNamesValue,
        eventDates: this.eventDatesValue,
        eventSpans: this.eventSpansValue,
      }
    });

    this.app.ports.adjustBegin.subscribe(months => {
      this.beginMenuTarget.value = months;
    });

    document.getElementById("weight-graph").addEventListener("click", e => {
      const pt = e.target.createSVGPoint();
      pt.x = e.clientX;
      pt.y = e.clientY;
      const qt = pt.matrixTransform(e.target.getScreenCTM().inverse());
      this.app.ports.changeCross.send([Math.round(qt.x), Math.round(qt.y)]);
    });
  }

  changeBegin(e) {
    this.app.ports.changeBegin.send(parseInt(e.target.value));
  }

  changeEnd(e) {
    this.app.ports.changeEnd.send(parseInt(e.target.value));
  }

  changeUnits(e) {
    this.app.ports.changeUnits.send(e.target.value);
  }

  moveCross(e) {
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
        this.app.ports.updateCross.send([0,-d]);
        break;
      case 75: // k
      case 38: // up arrow
        e.preventDefault(); // otherwise up arrow may scroll page
        this.app.ports.updateCross.send([0,d]);
        break;
    }
  }
}
