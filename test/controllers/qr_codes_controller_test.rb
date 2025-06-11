require "test_helper"

class QrCodesControllerTest < ActionDispatch::IntegrationTest
  test "generate and download qr" do
    post qr_code_url, params: { url: "https://example.com" }
    assert_response :success

    get qr_code_url(url: "https://example.com")
    assert_equal "image/png", @response.media_type
  end
end
