module Api
  module V1
    class ShortLinksController < ApiController
      def create
        short_link = current_user.short_links.find_or_create_by!(original_url: params[:original_url])

        render json: {
          short_url: redirect_short_url(short_link.short_code),
          short_code: short_link.short_code
        }
      rescue => e
        render json: { error: e.message }, status: 422
      end
    end
  end
end
