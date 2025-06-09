require "test_helper"

class ShortLinksControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.create!(email: "test@example.com", password: "password")
    @verifier = ActiveSupport::MessageVerifier.new(Rails.application.secret_key_base)
  end

  test "guest cannot create without token" do
    post short_links_url, params: { short_link: { original_url: "https://example.com" } }
    assert_response :forbidden
  end

  test "guest can create with valid token" do
    token = @verifier.generate(guest_mode: true)
    GoogleSafeBrowsingService.stub(:safe_url?, true) do
      assert_difference("ShortLink.count", 1) do
        post short_links_url, params: { short_link: { original_url: "https://example.com" }, guest_token: token }
      end
    end
  end

  test "authenticated user can create" do
    sign_in @user
    GoogleSafeBrowsingService.stub(:safe_url?, true) do
      assert_difference("ShortLink.count", 1) do
        post short_links_url, params: { short_link: { original_url: "https://example.com" } }
      end
    end
  end

  test "authenticated user can destroy" do
    sign_in @user
    link = ShortLink.create!(original_url: "https://example.com", user: @user)
    assert_difference("ShortLink.count", -1) do
      delete short_link_url(link)
    end
  end
end
