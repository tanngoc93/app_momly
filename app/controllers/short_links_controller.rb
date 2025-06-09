# frozen_string_literal: true

class ShortLinksController < ApplicationController
  include ActionView::RecordIdentifier
  include Pagy::Backend

  skip_before_action :authenticate_user!, only: %i[create redirect]

  before_action :ensure_guest_or_user!, only: :create
  before_action :set_short_link, only: %i[destroy redirect stats]

  rescue_from ActiveRecord::RecordInvalid, with: :handle_record_invalid
  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found
  rescue_from URI::InvalidURIError, ArgumentError, with: :handle_invalid_url
  rescue_from ShortLinkServices::BlockedDomainError, with: :respond_error
  rescue_from ShortLinkServices::UnsafeUrlError, with: :respond_error
  rescue_from StandardError, with: :handle_unexpected_error

  def create
    @short_link = ShortLinkServices::Create.new(
      user: current_user,
      original_url: short_link_params[:original_url]
    ).call

    respond_success("Link shortened!")
  end

  def destroy
    if @short_link.destroy
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
    track_click

    render :wait_redirect, layout: "minimal"
  end

  def stats
    @clicks_by_date = @short_link.short_link_clicks.group("DATE(created_at)").count
    @clicks_by_ip = @short_link.short_link_clicks.group(:ip).count

    respond_to do |format|
      format.html
      format.json { render json: { clicks_by_date: @clicks_by_date, clicks_by_ip: @clicks_by_ip } }
    end
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
    return false unless data.is_a?(Hash)

    guest_mode = data["guest_mode"] == true || data[:guest_mode] == true
    issued_at = data["issued_at"] || data[:issued_at]

    return false unless guest_mode && issued_at.present?

    issued_time = Time.at(issued_at.to_i)
    within_window = issued_time <= Time.current && (Time.current - issued_time) <= 30.minutes

    within_window
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

  def handle_record_invalid(exception)
    respond_error(exception.record.errors.full_messages.join(', '))
  end

  def handle_record_not_found(exception)
    respond_error("Record not found: #{exception.message}")
  end

  def handle_invalid_url(exception)
    respond_error("Invalid URL: #{exception.message}")
  end

  def handle_unexpected_error(exception)
    Rails.logger.error <<~LOG
      [ShortLinksController] Unexpected error:
      #{exception.class} - #{exception.message}
      #{exception.backtrace&.take(10)&.join("\n")}
    LOG
    respond_error("Unexpected error: #{exception.class.name}")
  end

  def set_short_link
    @short_link = if action_name == 'redirect'
                    ShortLink.find_by!(short_code: params[:short_code])
                  else
                    current_user.short_links.find(params[:id])
                  end
  end

  def track_click
    @short_link.increment!(:click_count)
    @short_link.update_column(:last_accessed_at, Time.current)
    @short_link.short_link_clicks.create(
      ip: request.remote_ip,
      referrer: request.referrer,
      user_agent: request.user_agent
    )
  end
end
