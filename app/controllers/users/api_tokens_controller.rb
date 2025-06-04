# frozen_string_literal: true

class Users::ApiTokensController < ApplicationController
  before_action :authenticate_user!

  def reset
    current_user.reset_api_token!

    respond_to do |format|
      format.html { redirect_to after_api_token_reset_path, notice: "Your API token has been reset successfully." }
      format.json { render json: { api_token: current_user.api_token }, status: :ok }
    end

  rescue => e
    respond_to do |format|
      format.html { redirect_to after_api_token_reset_path, alert: "Something went wrong while resetting your API token." }
      format.json { render json: { error: "Failed to reset API token", detail: e.message }, status: :internal_server_error }
    end
  end

  protected

  def after_api_token_reset_path
    edit_user_registration_path
  end
end
