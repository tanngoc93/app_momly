# frozen_string_literal: true

module Api
  module V1
    class ShortLinksController < ApiController
      def index
        @pagy, short_links = pagy(current_user.short_links.order(created_at: :desc))

        render json: {
          data: short_links.map { |link| serialized_link(link) },
          pagy: {
            page: @pagy.page,
            items: @pagy.items,
            pages: @pagy.pages,
            count: @pagy.count
          }
        }
      end

      def show
        short_link = current_user.short_links.find_by(id: params[:id])
        return render_not_found unless short_link

        render json: { data: serialized_link(short_link) }
      end

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

      def update
        short_link = current_user.short_links.find_by(id: params[:id])
        return render_not_found unless short_link

        if short_link.update(original_url: params[:original_url])
          render json: { data: serialized_link(short_link) }
        else
          render json: {
            errors: short_link.errors.full_messages.map { |m| { detail: m } }
          }, status: :unprocessable_entity
        end
      rescue ShortLinkServices::BlockedDomainError,
             ShortLinkServices::UnsafeUrlError,
             URI::InvalidURIError, ArgumentError => e
        render json: {
          errors: [ { detail: e.message } ]
        }, status: :unprocessable_entity
      end

      def destroy
        short_link = current_user.short_links.find_by(id: params[:id])
        return render_not_found unless short_link

        short_link.destroy
        head :no_content
      end

      private

      def serialized_link(link)
        {
          id: link.id,
          original_url: link.original_url,
          short_code: link.short_code,
          short_url: redirect_short_url(link.short_code),
          click_count: link.click_count,
          created_at: link.created_at,
          updated_at: link.updated_at
        }
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
        
      def render_not_found
        render json: {
          errors: [ { detail: 'Not Found' } ]
        }, status: :not_found
      end
    end
  end
end
