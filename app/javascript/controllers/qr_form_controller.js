import { Controller } from "@hotwired/stimulus"
import { Modal } from "bootstrap"

export default class extends Controller {
  static values = { modalId: String }

  connect() {
    const element = document.getElementById(this.modalIdValue)
    if (element) {
      this.modal = Modal.getOrCreateInstance(element)
    }
  }

  submitEnd(event) {
    if (this.modal && event.detail.success) {
      this.modal.show()
    }
  }
}
