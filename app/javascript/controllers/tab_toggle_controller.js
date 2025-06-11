import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]

  connect() {
    this.updateClasses()
    this.buttonTargets.forEach(btn => {
      btn.addEventListener('shown.bs.tab', () => {
        this.updateClasses()
        this.resetFormsAndResult()
      })
    })
  }

  updateClasses() {
    this.buttonTargets.forEach(btn => {
      if (btn.classList.contains('active')) {
        btn.classList.add('btn-light')
        btn.classList.remove('btn-outline-light')
      } else {
        btn.classList.remove('btn-light')
        btn.classList.add('btn-outline-light')
      }
    })
  }

  resetFormsAndResult() {
    const frame = document.getElementById('form_response')
    if (frame) frame.innerHTML = ''

    const shortForm = document.querySelector("form[action='/short_links']")
    if (shortForm) shortForm.reset()

    const qrForm = document.querySelector("form[action='/qr_code']")
    if (qrForm) qrForm.reset()
  }
}
