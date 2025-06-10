require "test_helper"

class PublicLinksControllerTest < ActionDispatch::IntegrationTest
  test "should list only publicly visible links created via web" do
    user = User.create!(email: "user@example.com", password: "password")

    ShortLink.create!(original_url: "https://webuser.com", short_code: "web001", publicly_visible: true, user: user, source: :web)
    ShortLink.create!(original_url: "https://legacy.com", short_code: "legacy01", publicly_visible: true)
    ShortLink.create!(original_url: "https://api.com", short_code: "api001", publicly_visible: true, source: :api)
    ShortLink.create!(original_url: "https://hidden.com", short_code: "hidden01", publicly_visible: false, source: :web)

    get public_links_url
    assert_response :success
    assert_includes @response.body, "web001"
    assert_includes @response.body, "legacy01"
    refute_includes @response.body, "api001"
    refute_includes @response.body, "hidden01"
  end
end
