# frozen_string_literal: true

module ShortLinkServices
  class Create
    def initialize(user:, original_url:)
      @user = user
      @original_url = original_url
    end

    def call
      normalized_url = normalize_url(@original_url)
      raise ArgumentError, "original_url can't be blank" if normalized_url.blank?

      scope = ShortLink.where(user_id: @user&.id)
      existing_link = scope.find_by(original_url: normalized_url)
      return existing_link if existing_link

      ShortLink.create!(
        original_url: normalized_url,
        user: @user
      )
    end

    private

    def normalize_url(url)
      uri = URI.parse(url.strip)
      uri.scheme ||= "https"
      uri.to_s
    rescue URI::InvalidURIError
      raise ArgumentError, "Invalid URL format"
    end
  end
end
