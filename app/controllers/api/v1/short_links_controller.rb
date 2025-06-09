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

      def stats
        short_link = current_user.short_links.find(params[:id])
        clicks_by_date = short_link.short_link_clicks.group("DATE(created_at)").count
        clicks_by_ip = short_link.short_link_clicks.group(:ip).count

        render json: {
          data: {
            clicks_by_date: clicks_by_date,
            clicks_by_ip: clicks_by_ip
          }
        }
      rescue ActiveRecord::RecordNotFound
        render json: { errors: [{ detail: "Not found" }] }, status: :not_found
      end
    end
  end
end
