require "test_helper"

class PublicLinksControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    ShortLink.create!(original_url: "https://example.com", short_code: "abc123", publicly_visible: true)
    ShortLink.create!(original_url: "https://hidden.com", short_code: "zzz999", publicly_visible: false)

    get public_links_url
    assert_response :success
    assert_includes @response.body, "abc123"
    refute_includes @response.body, "zzz999"
  end
end
