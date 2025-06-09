import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.addEventListener("show.bs.modal", () => {
      const frame = this.element.querySelector("turbo-frame")
      if (frame) {
        frame.src = frame.dataset.src
      }
    })
  }
}
