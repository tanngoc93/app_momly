# frozen_string_literal: true

module Api
  module V1
    class ShortLinksController < ApiController
      def create
        short_link = ShortLinkServices::Create.new(
          user: current_user,
          original_url: params[:original_url]
        ).call

        render json: {
          short_url: redirect_short_url(short_link.short_code),
          short_code: short_link.short_code
        }
      rescue ArgumentError, ActiveRecord::RecordInvalid => e
        render json: { error: e.message }, status: :unprocessable_entity
      end
    end
  end
end
