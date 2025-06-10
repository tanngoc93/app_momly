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
    issued_at = Time.current
    token = @verifier.generate(
      guest_mode: true,
      issued_at: issued_at.to_i,
      expires_at: (issued_at + 30.minutes).to_i
    )
    GoogleSafeBrowsingService.stub(:safe_url?, true) do
      PageMetadataFetcher.stub(:fetch, { title: "t", description: "d" }) do
        assert_difference("ShortLink.count", 1) do
          post short_links_url, params: { short_link: { original_url: "https://example.com" }, guest_token: token }
        end
      end
    end
  end

  test "guest can hide link from public" do
    issued_at = Time.current
    token = @verifier.generate(
      guest_mode: true,
      issued_at: issued_at.to_i,
      expires_at: (issued_at + 30.minutes).to_i
    )
    GoogleSafeBrowsingService.stub(:safe_url?, true) do
      PageMetadataFetcher.stub(:fetch, { title: "t", description: "d" }) do
        post short_links_url, params: { short_link: { original_url: "https://example.com", publicly_visible: "0" }, guest_token: token }
      end
    end
    assert_equal false, ShortLink.last.publicly_visible
  end

  test "guest link defaults to hidden" do
    issued_at = Time.current
    token = @verifier.generate(
      guest_mode: true,
      issued_at: issued_at.to_i,
      expires_at: (issued_at + 30.minutes).to_i
    )
    GoogleSafeBrowsingService.stub(:safe_url?, true) do
      PageMetadataFetcher.stub(:fetch, { title: "t", description: "d" }) do
        post short_links_url, params: { short_link: { original_url: "https://example.com" }, guest_token: token }
      end
    end
    assert_equal false, ShortLink.last.publicly_visible
  end

  test "guest cannot create with expired token" do
    issued_at = 31.minutes.ago
    token = @verifier.generate(
      guest_mode: true,
      issued_at: issued_at.to_i,
      expires_at: (issued_at + 30.minutes).to_i
    )
    GoogleSafeBrowsingService.stub(:safe_url?, true) do
      assert_no_difference("ShortLink.count") do
        post short_links_url, params: { short_link: { original_url: "https://example.com" }, guest_token: token }
      end
      assert_response :forbidden
    end
  end

  test "authenticated user can create" do
    sign_in @user
    GoogleSafeBrowsingService.stub(:safe_url?, true) do
      PageMetadataFetcher.stub(:fetch, { title: "t", description: "d" }) do
        assert_difference("ShortLink.count", 1) do
          post short_links_url, params: { short_link: { original_url: "https://example.com" } }
        end
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
