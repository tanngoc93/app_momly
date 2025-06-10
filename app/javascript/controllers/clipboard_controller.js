import { Controller } from "@hotwired/stimulus"
import $ from "jquery"

export default class extends Controller {
  static targets = ["source", "label"]
  static values = { text: String }

  copy(event) {
    if (event?.defaultPrevented) return
    event?.preventDefault()

    const $btn = $(event?.currentTarget || this.element)
    const $label = $btn.find(".clipboard-label")

    // Ưu tiên theo thứ tự: textValue > data-clipboard-text > sourceTarget
    let text = this.textValue?.trim()
    if (!text) {
      text = this.element.dataset.clipboardText
    }
    if (!text && this.hasSourceTarget) {
      text = $(this.sourceTarget).val() || $(this.sourceTarget).text()
    }
    if (!text) return

    navigator.clipboard.writeText(text).then(() => {
      const original = $label.data("original") || $label.text()
      $label.data("original", original)

      $label.text("Copied!")
      $btn.addClass("btn-success")
      $btn.removeClass("btn-outline-secondary btn-outline-primary btn-outline-success")

      setTimeout(() => {
        $label.text(original)
        $btn.removeClass("btn-success")
        $btn.addClass("btn-outline-secondary")
      }, 1500)
    }).catch(err => {
      alert(`Copy failed: ${err}`)
    })
  }
}
