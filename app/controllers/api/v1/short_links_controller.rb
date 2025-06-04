# frozen_string_literal: true

module Api
  module V1
    class ShortLinksController < ApiController
      def create
        short_link = ShortLinkServices::Create.new(
          user: current_user,
          original_url: params[:original_url],
          source: :api
        ).call

        render json: {
          data: {
            short_url: redirect_short_url(short_link.short_code),
            short_code: short_link.short_code
          }
        }, status: :created
      rescue => e
        render json: {
          errors: [
            { detail: e.message }
          ]
        }, status: :unprocessable_entity
      end
    end
  end
end
