require "test_helper"

class CleanupOldShortLinkClicksJobTest < ActiveJob::TestCase
  test "deletes clicks older than retention window" do
    link = ShortLink.create!(original_url: "https://example.com")
    old_click = link.short_link_clicks.create!(created_at: 91.days.ago)
    recent_click = link.short_link_clicks.create!(created_at: 10.days.ago)

    ENV["SHORT_LINK_CLICK_RETENTION_DAYS"] = "90"
    assert_difference("ShortLinkClick.count", -1) do
      CleanupOldShortLinkClicksJob.perform_now
    end

    assert_not ShortLinkClick.exists?(old_click.id)
    assert ShortLinkClick.exists?(recent_click.id)
  ensure
    ENV.delete("SHORT_LINK_CLICK_RETENTION_DAYS")
  end
end
