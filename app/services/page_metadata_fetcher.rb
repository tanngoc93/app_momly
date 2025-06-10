class PageMetadataFetcher
  def self.fetch(url)
    response = Faraday.get(url)
    return {} unless response.status.between?(200, 399)

    html = Nokogiri::HTML(response.body)
    {
      title: html.at('title')&.text&.strip,
      description: html.at('meta[name="description"]')&.[]('content')&.strip
    }
  rescue StandardError => e
    Rails.logger.warn("[MetadataFetcher] Failed to fetch #{url}: #{e.message}")
    {}
  end
end
