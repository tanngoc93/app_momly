module ApplicationHelper
  include Pagy::Frontend

  def nav_button_class(name)
    path = case name
           when :login
             new_user_session_path
           when :signup
             new_user_registration_path
           end
    return "btn btn-outline-light btn-sm" unless path

    current_page?(path) ? "btn btn-light btn-sm" : "btn btn-outline-light btn-sm"
  end

  def signed_guest_token
    verifier = ActiveSupport::MessageVerifier.new(Rails.application.secret_key_base)
    issued_at = Time.current
    payload = {
      guest_mode: true,
      issued_at: issued_at.to_i,
      expires_at: (issued_at + 30.minutes).to_i
    }
    verifier.generate(payload)
  end
end
