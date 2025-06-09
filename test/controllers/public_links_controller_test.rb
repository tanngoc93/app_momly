require "test_helper"

class PublicLinksControllerTest < ActionDispatch::IntegrationTest
  test "should list only publicly visible guest links" do
    ShortLink.create!(original_url: "https://example.com", short_code: "abc123", publicly_visible: true, user_id: nil)
    user = User.create!(email: "user@example.com", password: "password")
    ShortLink.create!(original_url: "https://member.com", short_code: "mem001", publicly_visible: true, user: user)
    ShortLink.create!(original_url: "https://hidden.com", short_code: "zzz999", publicly_visible: false, user_id: nil)

    get public_links_url
    assert_response :success
    assert_includes @response.body, "abc123"
    refute_includes @response.body, "mem001"
    refute_includes @response.body, "zzz999"
  end
end
