class CleanupExpiredGuestLinksJob < ApplicationJob
  queue_as :default

  def perform
    ShortLink.where(user_id: nil)
             .where("last_accessed_at IS NULL OR last_accessed_at < ?", 30.days.ago)
             .delete_all
  end
end
