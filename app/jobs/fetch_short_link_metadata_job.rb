class FetchShortLinkMetadataJob < ApplicationJob
  queue_as :default

  def perform(short_link_id)
    short_link = ShortLink.find_by(id: short_link_id)
    return unless short_link

    metadata = PageMetadataFetcher.fetch(short_link.original_url)
    short_link.update(
      page_title: metadata[:title],
      meta_description: metadata[:description]
    )
  rescue StandardError => e
    Rails.logger.error(
      "[FetchShortLinkMetadataJob] Failed for #{short_link_id}: #{e.class} - #{e.message}"
    )
  end
end
