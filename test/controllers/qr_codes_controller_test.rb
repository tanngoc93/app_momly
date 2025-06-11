require "test_helper"

class QrCodesControllerTest < ActionDispatch::IntegrationTest
  test "generate and download qr" do
    GoogleSafeBrowsingService.stub(:safe_url?, true) do
      post qr_code_url, params: { url: "https://example.com" }
      assert_response :success
    end

    get qr_code_url(url: "https://example.com")
    assert_equal "image/png", @response.media_type
  end

  test "invalid url returns unprocessable entity" do
    post qr_code_url, params: { url: "bad" }
    assert_response :unprocessable_entity
  end
end
