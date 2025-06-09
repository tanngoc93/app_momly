import { Controller } from "@hotwired/stimulus"
import $ from "jquery"

export default class extends Controller {
  static targets = ["source"]
  static values = { text: String }

  copy(event) {
    if (event) event.preventDefault()
    let text = this.textValue
    if (!text && this.hasSourceTarget) {
      text = $(this.sourceTarget).val() || $(this.sourceTarget).text()
    }
    if (!text) return

    navigator.clipboard.writeText(text).then(() => {
      const $btn = $(event && event.currentTarget ? event.currentTarget : this.element)
      const original = $btn.html()
      $btn.html('<i class="bi bi-check-circle me-1"></i> Copied!')
      $btn.addClass("btn-success")
      $btn.removeClass("btn-outline-primary btn-outline-secondary btn-outline-success")

      setTimeout(() => {
        $btn.html(original)
        $btn.removeClass("btn-success")
        $btn.addClass("btn-outline-primary")
      }, 1500)
    }).catch(err => {
      alert(`Copy failed: ${err}`)
    })
  }
}
