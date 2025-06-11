require "rqrcode"
class QrCodesController < ApplicationController
  skip_before_action :authenticate_user!

  def create
    @url = params[:url].to_s.strip
    if @url.blank? || !@url.match?(/\Ahttps?:\/\//)
      @error = "Invalid URL"
      render partial: "qr_codes/form", status: :unprocessable_entity
    else
      respond_to do |format|
        format.turbo_stream
        format.html { render :create }
      end
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
end
