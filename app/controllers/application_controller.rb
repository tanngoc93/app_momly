# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Backend

  before_action :authenticate_user!, unless: :admin_request?
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def after_sign_in_path_for(resource)
    root_path
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  def admin_request?
    request.path.start_with?("/admin")
  end

  private

  # Extract the true client IP when behind proxies like Cloudflare
  # Priority: CF-Connecting-IP -> X-Real-IP -> first X-Forwarded-For -> remote_ip
  def real_ip
    request.headers['CF-Connecting-IP'].presence ||
      request.headers['X-Real-IP'].presence ||
      request.headers['X-Forwarded-For']&.split(',')&.first&.strip ||
      request.remote_ip
  end
end
