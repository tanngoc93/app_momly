# frozen_string_literal: true

class GoogleSafeBrowsingService
  API_KEY = ENV['GOOGLE_SAFE_BROWSING_API_KEY']
  API_URL = "https://safebrowsing.googleapis.com/v4/threatMatches:find"

  # Public method to check if a given URL is safe.
  # It returns false if:
  # - The URL is unreachable (dead)
  # - The URL is flagged by Google Safe Browsing
  #
  # Returns true only if the URL is reachable and not blacklisted
  def self.safe_url?(url)
    return false unless url_alive?(url)
    return false if blacklisted_by_google?(url)

    true
  rescue => e
    Rails.logger.error("[SafeBrowsing] Unexpected error: #{e.message}")
    false
  end

  # Checks if the URL is alive (responds with 2xx or 3xx HTTP status)
  def self.url_alive?(url)
    Faraday.head(url).status.in?(200..399)
  rescue Faraday::Error => e
    Rails.logger.warn("[SafeBrowsing] URL unreachable: #{url} (#{e.class.name})")
    false
  end

  # Checks if the URL is blacklisted by Google Safe Browsing
  # for threats like malware, phishing, and unwanted software.
  def self.blacklisted_by_google?(url)
    response = Faraday.post("#{API_URL}?key=#{API_KEY}") do |req|
      req.headers['Content-Type'] = 'application/json'
      req.body = {
        client: {
          clientId: "momly",
          clientVersion: "1.0"
        },
        threatInfo: {
          threatTypes: %w[
            MALWARE
            SOCIAL_ENGINEERING
            UNWANTED_SOFTWARE
            POTENTIALLY_HARMFUL_APPLICATION
          ],
          platformTypes: ["ANY_PLATFORM"],
          threatEntryTypes: ["URL"],
          threatEntries: [{ url: url }]
        }
      }.to_json
    end

    body = JSON.parse(response.body)
    body["matches"].present?
  rescue => e
    Rails.logger.error("[SafeBrowsing] Google API check failed for #{url}: #{e.message}")
    false # Fallback: assume safe if API fails
  end
end
