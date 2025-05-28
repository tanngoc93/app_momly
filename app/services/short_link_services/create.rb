# frozen_string_literal: true

module ShortLinkServices
  class Create
    def initialize(user:, original_url:)
      @user = user
      @original_url = original_url
    end

    # Main entrypoint to create a short link
    # - Normalizes the input URL
    # - Checks if it's blank or invalid
    # - Verifies the URL is safe using Google Safe Browsing API
    # - Returns existing short link if found
    # - Otherwise, creates a new one
    def call
      normalized_url = normalize_url(@original_url)
      raise ArgumentError, "original_url can't be blank" if normalized_url.blank?

      unless GoogleSafeBrowsingService.safe_url?(normalized_url)
        raise StandardError, "URL is unsafe or unreachable"
      end

      scope = ShortLink.where(user_id: @user&.id)
      existing_link = scope.find_by(original_url: normalized_url)
      return existing_link if existing_link

      ShortLink.create!(
        original_url: normalized_url,
        user: @user
      )
    end

    private

    # Normalizes the input URL by:
    # - Stripping whitespace
    # - Ensuring the scheme (defaults to https)
    # Raises ArgumentError if the URL is invalid
    def normalize_url(url)
      stripped = url.strip

      uri = URI.parse(stripped)
      unless uri.scheme&.match?(/^https?$/)
        uri = URI.parse("https://#{stripped}")
      end

      uri.to_s
    rescue URI::InvalidURIError
      raise ArgumentError, "Invalid URL format"
    end
  end
end
