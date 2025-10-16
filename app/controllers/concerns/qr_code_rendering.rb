# frozen_string_literal: true

module QrCodeRendering
  extend ActiveSupport::Concern

  private

  def generate_qr_png(data)
    qr = RQRCode::QRCode.new(data)
    qr.as_png(**qr_png_options)
  end

  def qr_png_options
    {
      border_modules: 2,
      module_px_size: 16,
      color: "000000",
      fill: "ffffff"
    }
  end
end
