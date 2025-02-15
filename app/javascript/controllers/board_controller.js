import { Controller } from "@hotwired/stimulus"
import { Elm } from "elm_board";

export default class extends Controller {
  static values = {
    fen: String,
    marks: Array,
    notation: Boolean,
    orientation: String,
    pointer: Boolean,
    scheme: String,
  }

  connect() {
    const flags = {};
    if (this.hasFenValue)         flags["fen"]         = this.fenValue;
    if (this.hasMarksValue)       flags["marks"]       = this.marksValue;
    if (this.hasNotationValue)    flags["notation"]    = this.notationValue;
    if (this.hasOrientationValue) flags["orientation"] = this.orientationValue;
    if (this.hasPointerValue)     flags["pointer"]     = this.pointerValue;
    if (this.hasSchemeValue)      flags["scheme"]      = this.schemeValue;
    Elm.Board.init({ node: this.element, flags: flags });
  }
}

