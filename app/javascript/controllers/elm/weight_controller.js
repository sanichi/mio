import { Controller } from "@hotwired/stimulus"
import { Elm } from "elm_weight"

export default class extends Controller {
  static targets = [ "elm" ]

  static values = {
    begin: Number,
    end: Number,
    units: String,
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
        beginEnd: [this.beginValue, this.endValue],
        units: this.unitsValue,
        kilos: this.kilosValue,
        dates: this.datesValue,
        debug: this.debugValue,
        eventNames: this.eventNamesValue,
        eventDates: this.eventDatesValue,
        eventSpans: this.eventSpansValue,
      }
    });

    const controller = this;
    document.getElementById("weight").addEventListener("click", (e) => {
      const pt = e.target.createSVGPoint();
      pt.x = e.clientX;
      pt.y = e.clientY;
      const qt = pt.matrixTransform(e.target.getScreenCTM().inverse());
      controller.app.ports.changeCross.send([Math.round(qt.x), Math.round(qt.y)]);
    });
  }

  changeBegin(e) {
    this.app.ports.changeBegin.send(parseInt(e.target.value));
  }

  changeEnd(e) {
    const end_year = parseInt(e.target.value);
    this.app.ports.changeEnd.send(end_year);

    // Don't let the graph show less than 12 months if the end is a particular year rather than 0 (meaning now).
    var begin_months = parseInt(document.getElementById("begin").value);
    if (end_year > 0 && begin_months != 0 && begin_months < 12) {
      begin_months = 12;
      document.getElementById("begin").value = begin_months;
      this.app.ports.changeBegin.send(begin_months);
    }
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
