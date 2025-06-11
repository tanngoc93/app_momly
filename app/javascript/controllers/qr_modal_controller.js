import { Controller } from "@hotwired/stimulus"
import { Modal } from "bootstrap"

export default class extends Controller {
  connect() {
    this.modal = Modal.getOrCreateInstance(this.element)
  }

  show() {
    if (this.modal) {
      this.modal.show()
    }
  }
}
