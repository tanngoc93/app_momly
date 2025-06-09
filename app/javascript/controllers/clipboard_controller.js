import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source"]
  static values = { text: String }

  copy(event) {
    event.preventDefault()
    let text = this.textValue
    if (!text && this.hasSourceTarget) {
      text = this.sourceTarget.value || this.sourceTarget.textContent
    }
    if (!text) return

    navigator.clipboard.writeText(text).then(() => {
      const btn = event.currentTarget
      const original = btn.innerHTML
      btn.innerHTML = '<i class="bi bi-check-circle me-1"></i> Copied!'
      btn.classList.add("btn-success")
      btn.classList.remove("btn-outline-primary", "btn-outline-secondary", "btn-outline-success")

      setTimeout(() => {
        btn.innerHTML = original
        btn.classList.remove("btn-success")
        btn.classList.add("btn-outline-primary")
      }, 1500)
    }).catch(err => {
      alert(`Copy failed: ${err}`)
    })
  }
}
