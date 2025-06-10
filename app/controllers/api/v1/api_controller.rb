# frozen_string_literal: true

module Api
  module V1
    class ApiController < ApplicationController
      skip_before_action :verify_authenticity_token
      skip_before_action :authenticate_user!

      before_action :authenticate_with_token!

      attr_reader :current_user

      private

      def authenticate_with_token!
        token = request.headers["Authorization"].to_s.remove("Bearer ").strip

        @current_user = User.find_by(api_token: token)

        unless @current_user
          render json: {
            errors: [
              { detail: "Unauthorized" }
            ]
          }, status: :unauthorized
        end
      end
    end
  end
end
