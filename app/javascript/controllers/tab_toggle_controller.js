import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]

  connect() {
    this.updateClasses()
    this.buttonTargets.forEach(btn => {
      btn.addEventListener('shown.bs.tab', () => this.updateClasses())
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
}
