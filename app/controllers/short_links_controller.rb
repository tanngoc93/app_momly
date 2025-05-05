class ShortLinksController < ApplicationController
  # Allow redirect action without authentication
  skip_before_action :authenticate_user!, only: [:redirect]

  def home
    @short_link = current_user.short_links.new
  end

  def create
    @short_link = current_user.short_links.find_by(original_url: short_link_params[:original_url]) ||
                  current_user.short_links.new(short_link_params)

    respond_to do |format|
      if @short_link.persisted? || @short_link.save
        format.turbo_stream
      else
        format.turbo_stream
      end
    end
  end

  def redirect
    short_link = ShortLink.find_by!(short_code: params[:short_code])
    short_link.increment!(:click_count)
    redirect_to short_link.original_url, allow_other_host: true
  end

  private

  def short_link_params
    params.require(:short_link).permit(:original_url)
  end
end
