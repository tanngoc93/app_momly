# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  def create
    captcha_passed = Rails.env.test? || Rails.env.development? || verify_recaptcha

    if captcha_passed
      super
    else
      redirect_to new_user_registration_path, alert: "It seems the CAPTCHA check failed. Could you please try again?"
    end
  end

  protected

  def update_resource(resource, params)
    # If password is provided, call super to handle update with password
    if params[:password].present?
      super
    else
      # Only remove password-related params if no password is provided
      [:password, :password_confirmation, :current_password].each { |key| params.delete(key) }

      # Update resource without password
      resource.update_without_password(params)
    end
  end
end
