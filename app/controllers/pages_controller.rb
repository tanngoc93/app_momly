class PagesController < ApplicationController
  skip_before_action :authenticate_user!

  def show
    slug = params[:slug].to_s
    raise ActiveRecord::RecordNotFound unless slug.match?(Page::SLUG_FORMAT)

    @page = Page.find_by!(slug: slug)
  end
end
