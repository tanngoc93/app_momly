class GenerateSitemapJob < ApplicationJob
  queue_as :default

  def perform
    SitemapGenerator.generate
  end
end
