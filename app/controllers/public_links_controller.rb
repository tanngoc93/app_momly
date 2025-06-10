# frozen_string_literal: true

class PublicLinksController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]

  def index
    @short_links = ShortLink.publicly_visible
                             .where(source: [nil, ShortLink.sources[:web]])
                             .order(created_at: :desc)
                             .limit(100)
  end
end
