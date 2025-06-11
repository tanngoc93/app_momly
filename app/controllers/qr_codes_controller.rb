require "rqrcode"
class QrCodesController < ApplicationController
  skip_before_action :authenticate_user!

  def create
    @url = params[:url].to_s

    begin
      @url = normalize_url(@url)
      raise ShortLinkServices::BlockedDomainError, "You cannot shorten a Momly link" if own_domain?(@url)

      unless GoogleSafeBrowsingService.safe_url?(@url)
        raise ShortLinkServices::UnsafeUrlError, "URL is unsafe or unreachable"
      end

      respond_to do |format|
        format.turbo_stream
        format.html { render :create }
      end
    rescue ArgumentError, ShortLinkServices::BlockedDomainError, ShortLinkServices::UnsafeUrlError => e
      @error = e.message
      render partial: "qr_codes/form", status: :unprocessable_entity
    end
  end

  def show
    url = params[:url].to_s
    qr = RQRCode::QRCode.new(url)
    png = qr.as_png(size: 300)
    if params[:download]
      send_data png.to_s, type: "image/png", disposition: "attachment", filename: "qr.png"
    else
      send_data png.to_s, type: "image/png", disposition: "inline"
    end
  end

  private

  def normalize_url(url)
    stripped = url.to_s.strip
    raise ArgumentError, "URL can't be blank" if stripped.blank?

    uri = URI.parse(stripped)
    unless uri.scheme&.match?(/^https?$/)
      uri = URI.parse("https://#{stripped}")
    end

    uri.to_s
  rescue URI::InvalidURIError
    raise ArgumentError, "Invalid URL format"
  end

  def own_domain?(url)
    uri = URI.parse(url)
    host = uri.host.to_s.downcase
    domains = Rails.application.config.momly_domains
    domains.any? { |domain| host == domain || host.end_with?(".#{domain}") }
  end
end
