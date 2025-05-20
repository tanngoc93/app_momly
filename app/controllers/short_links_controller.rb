# frozen_string_literal: true

class ShortLinksController < ApplicationController
  skip_before_action :authenticate_user!, only: [:redirect]

  def create
    @short_link = ShortLinkServices::Create.new(
      user: current_user,
      original_url: short_link_params[:original_url]
    ).call

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to root_path, notice: "Link shortened!" }
    end
  rescue ArgumentError, ActiveRecord::RecordInvalid => e
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to root_path, alert: e.message }
    end
  end

  def redirect
    @short_link = ShortLink.find_by!(short_code: params[:short_code])

    @short_link.increment!(:click_count)
    @short_link.update_column(:last_accessed_at, Time.current)

    render :wait_redirect, layout: "minimal"
  end

  def modal
    @short_links = current_user.short_links.order(updated_at: :desc)
    render partial: "short_links/modal_links"
  end

  private

  def short_link_params
    params.require(:short_link).permit(:original_url)
  end
end
