# frozen_string_literal: true

class ShortLinksController < ApplicationController
  include ActionView::RecordIdentifier
  include Pagy::Backend

  skip_before_action :authenticate_user!, only: [:create, :redirect]

  before_action :ensure_guest_or_user!, only: :create

  def create
    @short_link = ShortLinkServices::Create.new(
      user: current_user,
      original_url: short_link_params[:original_url]
    ).call

    respond_success("Link shortened!")

  rescue ActiveRecord::RecordInvalid => e
    respond_error(e.record.errors.full_messages.join(', '))

  rescue ActiveRecord::RecordNotFound => e
    respond_error("Record not found: #{e.message}")

  rescue URI::InvalidURIError, ArgumentError => e
    respond_error("Invalid URL: #{e.message}")

  rescue ShortLinkServices::BlockedDomainError => e
    respond_error(e.message)

  rescue ShortLinkServices::UnsafeUrlError => e
    respond_error(e.message)

  rescue => e
    Rails.logger.error <<~LOG
      [ShortLinksController#create] Unexpected error:
      #{e.class} - #{e.message}
      #{e.backtrace&.take(10)&.join("\n")}
    LOG
    respond_error("Unexpected error: #{e.class.name}")
  end

  def destroy
    @short_link = ShortLink.find_by(id: params[:id])

    if @short_link&.destroy
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.remove(dom_id(@short_link)) }
        format.html { redirect_back fallback_location: root_path, notice: "Link removed." }
      end
    else
      respond_to do |format|
        format.turbo_stream { head :unprocessable_entity }
        format.html { redirect_back fallback_location: root_path, alert: "Failed to remove link." }
      end
    end
  end

  def redirect
    @short_link = ShortLink.find_by!(short_code: params[:short_code])
    @short_link.increment!(:click_count)
    @short_link.update_column(:last_accessed_at, Time.current)

    render :wait_redirect, layout: "minimal"
  end

  def modal
    @pagy, @short_links = pagy(current_user.short_links.order(updated_at: :desc), items: 20)
    render partial: "short_links/modal_links"
  end

  private

  def short_link_params
    params.require(:short_link).permit(:original_url)
  end

  def ensure_guest_or_user!
    return if current_user.present? || valid_guest_token?(params[:guest_token])

    head :forbidden
  end

  def valid_guest_token?(token)
    return false if token.blank?

    verifier = ActiveSupport::MessageVerifier.new(Rails.application.secret_key_base)
    data = verifier.verify(token)
    data.is_a?(Hash) && (data["guest_mode"] == true || data[:guest_mode] == true)
  rescue ActiveSupport::MessageVerifier::InvalidSignature, StandardError
    false
  end

  def respond_success(message)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to root_path, notice: message }
    end
  end

  def respond_error(message)
    @error_message = message

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to root_path, alert: message }
    end
  end
end
