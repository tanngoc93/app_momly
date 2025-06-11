class PagesController < ApplicationController
  skip_before_action :authenticate_user!

  def show
    @page = Page.find_by!(slug: params[:slug])
  end
end
