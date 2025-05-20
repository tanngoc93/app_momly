# frozen_string_literal: true

class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]

  def index
    @guest_mode = params[:guest_mode] == "on"
  end
end
