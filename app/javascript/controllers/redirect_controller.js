import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["countdown"]
  static values = { url: String, seconds: Number }

  connect() {
    this.remaining = this.secondsValue || 5
    this.update()
    this.timer = setInterval(() => this.tick(), 1000)
  }

  disconnect() {
    if (this.timer) clearInterval(this.timer)
  }

  tick() {
    this.remaining--
    this.update()
    if (this.remaining <= 0) {
      clearInterval(this.timer)
      window.location.href = this.urlValue
    }
  }

  update() {
    if (this.hasCountdownTarget) {
      this.countdownTarget.textContent = this.remaining
    }
  }

  goto() {
    window.location.href = this.urlValue
  }
}
