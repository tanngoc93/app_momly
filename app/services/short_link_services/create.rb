# frozen_string_literal: true

module ShortLinkServices

  class Create

    def initialize(user:, original_url:, publicly_visible: true, source: :web)
      @user = user
      @original_url = original_url
      @publicly_visible = publicly_visible
      @source = source
    end

    # Main entrypoint to create a short link
    # - Normalizes the input URL
    # - Checks if it's blank or invalid
    # - Blocks URLs that point to the same service (e.g., momly.me)
    # - Verifies the URL is safe using Google Safe Browsing API
    # - Returns existing short link if found
    # - Otherwise, creates a new one
    def call
      raise ArgumentError, "Original URL can't be blank" if @original_url.blank?

      normalized_url = normalize_url(@original_url)

      if own_domain?(normalized_url)
        raise BlockedDomainError, "You cannot shorten a Momly link"
      end

      unless GoogleSafeBrowsingService.safe_url?(normalized_url)
        raise UnsafeUrlError, "URL is unsafe or unreachable"
      end

      find_or_create_short_link(normalized_url)
    end

    private

    # Normalizes the input URL by:
    # - Stripping whitespace
    # - Ensuring the scheme (defaults to https if missing)
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

    # Checks if the URL points to the same domain (e.g., momly.me or subdomains)
    def own_domain?(url)
      uri = URI.parse(url)
      host = uri.host.to_s.downcase
      domains = Rails.application.config.momly_domains
      domains.any? { |domain| host == domain || host.end_with?(".#{domain}") }
    end

    # Returns existing short link for user if already exists
    # Otherwise, creates a new one
    def find_or_create_short_link(url)
      existing_link = ShortLink.where(user_id: @user&.id).find_by(original_url: url)
      return existing_link if existing_link

      ShortLink.create!(
        user: @user,
        original_url: url,
        publicly_visible: @publicly_visible,
        source: @source
      )
    end
  end
end
