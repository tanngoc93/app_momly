class PagesController < ApplicationController
  skip_before_action :authenticate_user!

  def show
    slug = params[:slug].to_s
    raise ActiveRecord::RecordNotFound unless slug.match?(Page::SLUG_FORMAT)

    @page = Page.find_by!(slug: slug)

    content_for :page_title, @page.meta_title.presence || @page.title
    content_for :meta_description, @page.meta_description if @page.meta_description.present?
  end
end
