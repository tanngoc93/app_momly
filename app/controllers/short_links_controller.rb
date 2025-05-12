class ShortLinksController < ApplicationController
  skip_before_action :authenticate_user!, only: [:redirect]

  def redirect
    @short_link = ShortLink.find_by!(short_code: params[:short_code])
    @short_link.increment!(:click_count)
    render :wait_redirect, layout: "minimal"
  end

  def create
    @short_link = current_user.short_links.find_by(original_url: short_link_params[:original_url]) ||
                  current_user.short_links.new(short_link_params)

    respond_to do |format|
      if @short_link.persisted? || @short_link.save
        format.turbo_stream
        format.html { redirect_to root_path, notice: "Link shortened!" }
      else
        format.turbo_stream
        format.html { render :home, status: :unprocessable_entity }
      end
    end
  end

  def modal
    @short_links = current_user.short_links.order(created_at: :desc)
    render partial: "short_links/modal_links"
  end

  private

  def short_link_params
    params.require(:short_link).permit(:original_url)
  end
end
