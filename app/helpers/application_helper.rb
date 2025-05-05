module ApplicationHelper
  def nav_button_class(name)
    if name == :login
      current_page?(new_user_session_path) ? "btn btn-light btn-sm" : "btn btn-outline-light btn-sm"
    elsif name == :signup
      current_page?(new_user_registration_path) ? "btn btn-light btn-sm" : "btn btn-outline-light btn-sm"
    end
  end
end
