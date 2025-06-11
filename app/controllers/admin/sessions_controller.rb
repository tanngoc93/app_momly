module Admin
  class SessionsController < ActiveAdmin::Devise::SessionsController
    skip_before_action :verify_authenticity_token, only: :create
  end
end
