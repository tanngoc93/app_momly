// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "bootstrap"
import $ from "jquery"

window.$ = $
window.jQuery = $

function handleClipboardCopy(e) {
  e.preventDefault();
  const $btn = $(e.currentTarget);
  const originalWidth = $btn.outerWidth();
  $btn.css("width", originalWidth);
  let text = $btn.data("clipboard-text");
  if (!text) {
    const $container = $btn.closest("[data-controller='clipboard']");
    const $source = $container.find("[data-clipboard-target='source']");
    if ($source.length) {
      text = $source.val() || $source.text();
    }
  }
  if (!text) return;

  navigator.clipboard.writeText(text).then(() => {
    const original = $btn.html();
    $btn.data("original-html", original);
    $btn.html('<i class="bi bi-check-circle me-1"></i> Copied!');
    $btn.addClass("btn-success");
    $btn.removeClass("btn-outline-primary btn-outline-secondary btn-outline-success");
    setTimeout(() => {
      $btn.html(original);
      $btn.removeClass("btn-success");
      $btn.addClass("btn-outline-primary");
      $btn.css("width", "");
    }, 1500);
  }).catch(err => {
    alert(`Copy failed: ${err}`);
  });
}

$(document).on("turbo:load", function () {
  $(document).off("click", "[data-action='clipboard#copy']", handleClipboardCopy);
  $(document).on("click", "[data-action='clipboard#copy']", handleClipboardCopy);
});
