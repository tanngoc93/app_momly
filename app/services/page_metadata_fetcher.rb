require 'uri'

class PageMetadataFetcher
  DEFAULT_OPEN_TIMEOUT = 5
  DEFAULT_TIMEOUT = 5
  MAX_BODY_SIZE = 1_000_000

  def self.fetch(url)
    uri = URI.parse(url)
    return {} unless uri.is_a?(URI::HTTP) && uri.host.present?

    response = Faraday.get(url) do |req|
      req.options.timeout = DEFAULT_TIMEOUT
      req.options.open_timeout = DEFAULT_OPEN_TIMEOUT
    end
    return {} unless response.status.between?(200, 399)
    return {} unless response.headers['content-type']&.include?('html')

    body = response.body.to_s[0, MAX_BODY_SIZE]
    html = Nokogiri::HTML(body)
    {
      title: html.at('title')&.text&.strip,
      description: html.at('meta[name="description"]')&.[]('content')&.strip
    }
  rescue StandardError => e
    Rails.logger.warn("[MetadataFetcher] Failed to fetch #{url}: #{e.message}")
    {}
  end
end
