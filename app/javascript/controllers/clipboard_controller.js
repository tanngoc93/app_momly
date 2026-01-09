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
    if (!text) return

    const showSuccess = () => {
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
    }

    const fallbackCopy = () => {
      const textarea = document.createElement("textarea")
      textarea.value = text
      textarea.setAttribute("readonly", "")
      textarea.style.position = "absolute"
      textarea.style.left = "-9999px"
      document.body.appendChild(textarea)
      textarea.select()
      const succeeded = document.execCommand("copy")
      document.body.removeChild(textarea)
      if (succeeded) {
        showSuccess()
      }
    }

    if (navigator.clipboard && window.isSecureContext) {
      navigator.clipboard.writeText(text)
        .then(showSuccess)
        .catch(err => {
          console.error(`Copy failed: ${err}`)
          fallbackCopy()
        })
      return
    }

    fallbackCopy()
  }
}
