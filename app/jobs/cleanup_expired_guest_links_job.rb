class CleanupExpiredGuestLinksJob < ApplicationJob
  queue_as :default

  def perform
    ShortLink.guest_links
             .where("last_accessed_at IS NULL OR last_accessed_at < ?", 30.days.ago)
             .delete_all
  end
end
