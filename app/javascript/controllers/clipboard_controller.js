import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source", "label"]
  static values = { text: String }

  copy(event) {
    if (event?.defaultPrevented) return
    event?.preventDefault()

    const btn = event?.currentTarget || this.element
    const label = btn.querySelector(".clipboard-label")

    let text = this.textValue?.trim()
    if (!text) {
      text = btn.dataset.clipboardText || this.element.dataset.clipboardText
    }
    if (!text && this.hasSourceTarget) {
      text = this.sourceTarget.value || this.sourceTarget.textContent
    }
    if (!text || !navigator.clipboard) return

    navigator.clipboard.writeText(text).then(() => {
      const original = label.dataset.original || label.textContent
      label.dataset.original = original

      label.textContent = "Copied!"
      btn.classList.add("btn-success")
      btn.classList.remove("btn-outline-secondary", "btn-outline-primary", "btn-outline-success")

      setTimeout(() => {
        label.textContent = original
        btn.classList.remove("btn-success")
        btn.classList.add("btn-outline-secondary")
      }, 1500)
    }).catch(err => console.error(`Copy failed: ${err}`))
  }
}
