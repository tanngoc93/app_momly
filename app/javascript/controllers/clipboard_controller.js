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

    let text = (this.textValue || "").trim()
    if (!text) {
      text = $btn.data("clipboard-text") || this.element.dataset.clipboardText
    }
    if (!text && this.hasSourceTarget) {
      const $source = $(this.sourceTarget)
      text = $source.val() || $source.text()
    }
    if (!text || !navigator.clipboard) return

    navigator.clipboard.writeText(text).then(() => {
      const original = $label.data("original") || $label.text()
      $label.data("original", original)

      $label.text("Copied!")
      $btn.addClass("btn-success")
      $btn.removeClass(
        "btn-outline-secondary btn-outline-primary btn-outline-success",
      )

      setTimeout(() => {
        $label.text(original)
        $btn.removeClass("btn-success")
        $btn.addClass("btn-outline-secondary")
      }, 1500)
    }).catch(err => {
      console.error(`Copy failed: ${err}`)
    })
  }
}
