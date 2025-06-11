ActiveAdmin.setup do |config|
  config.site_title = "App Momly"

  config.authentication_method = :authenticate_admin_user!
  config.current_user_method = :current_admin_user

  config.logout_link_path = :destroy_admin_user_session_path
  config.logout_link_method = :delete

  config.batch_actions = true
end
