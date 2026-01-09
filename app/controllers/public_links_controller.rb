# frozen_string_literal: true

class PublicLinksController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]

  def index
    @pagy, @short_links = pagy(
      ShortLink.publicly_visible
        .where(source: [nil, ShortLink.sources[:web]])
        .order(created_at: :desc),
      items: 100
    )
  end
end
