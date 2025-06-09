class CleanupOldShortLinkClicksJob < ApplicationJob
  queue_as :default

  def perform
    retention_days = ENV.fetch("SHORT_LINK_CLICK_RETENTION_DAYS", "90").to_i
    ShortLinkClick.where("created_at < ?", retention_days.days.ago).delete_all
  end
end
