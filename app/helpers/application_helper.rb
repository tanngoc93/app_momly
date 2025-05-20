module ApplicationHelper
  def nav_button_class(name)
    if name == :login
      current_page?(new_user_session_path) ? "btn btn-light btn-sm" : "btn btn-outline-light btn-sm"
    elsif name == :signup
      current_page?(new_user_registration_path) ? "btn btn-light btn-sm" : "btn btn-outline-light btn-sm"
    end
  end

  def signed_guest_token
    verifier = ActiveSupport::MessageVerifier.new(Rails.application.secret_key_base)
    verifier.generate({ guest_mode: true, issued_at: Time.current.to_i })
  end
end
