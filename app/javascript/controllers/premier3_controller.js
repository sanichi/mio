import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    home: Number,     // initial start position to return to
    start: Number,    // current start position (0-28)
    complete: Boolean // whether season is complete (no home button)
  }

  static targets = [
    "table",
    "firstBtn",
    "back5Btn",
    "back1Btn",
    "homeBtn",
    "forward1Btn",
    "forward5Btn",
    "lastBtn"
  ]

  connect() {
    this.updateButtons()
  }

  first() {
    this.startValue = 0
    this.updateDisplay()
  }

  back5() {
    this.startValue = Math.max(0, this.startValue - 5)
    this.updateDisplay()
  }

  back1() {
    this.startValue = Math.max(0, this.startValue - 1)
    this.updateDisplay()
  }

  home() {
    this.startValue = this.homeValue
    this.updateDisplay()
  }

  forward1() {
    this.startValue = Math.min(28, this.startValue + 1)
    this.updateDisplay()
  }

  forward5() {
    this.startValue = Math.min(28, this.startValue + 5)
    this.updateDisplay()
  }

  last() {
    this.startValue = 28
    this.updateDisplay()
  }

  updateDisplay() {
    this.updateColumns()
    this.updateButtons()
  }

  updateColumns() {
    const start = this.startValue
    const end = start + 9

    // Find all cells with data-col attribute
    const cells = this.tableTarget.querySelectorAll("[data-col]")
    cells.forEach(cell => {
      const col = parseInt(cell.dataset.col, 10)
      if (col >= start && col <= end) {
        cell.classList.remove("d-none")
      } else {
        cell.classList.add("d-none")
      }
    })
  }

  updateButtons() {
    const start = this.startValue
    const atFirst = start === 0
    const atLast = start === 28
    const atHome = start === this.homeValue

    // Disable buttons at boundaries
    this.firstBtnTarget.disabled = atFirst
    this.back5BtnTarget.disabled = atFirst
    this.back1BtnTarget.disabled = atFirst

    this.forward1BtnTarget.disabled = atLast
    this.forward5BtnTarget.disabled = atLast
    this.lastBtnTarget.disabled = atLast

    // Home button only exists if season not complete
    if (this.hasHomeBtnTarget) {
      this.homeBtnTarget.disabled = atHome
    }
  }
}
