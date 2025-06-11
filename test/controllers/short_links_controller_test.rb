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
      FetchShortLinkMetadataJob.stub(:perform_async, nil) do
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
      FetchShortLinkMetadataJob.stub(:perform_async, nil) do
        post short_links_url, params: { short_link: { original_url: "https://example.com", publicly_visible: "0" }, guest_token: token }
      end
    end
    assert_equal false, ShortLink.last.publicly_visible
  end

  test "guest can make link public" do
    issued_at = Time.current
    token = @verifier.generate(
      guest_mode: true,
      issued_at: issued_at.to_i,
      expires_at: (issued_at + 30.minutes).to_i
    )
    GoogleSafeBrowsingService.stub(:safe_url?, true) do
      FetchShortLinkMetadataJob.stub(:perform_async, nil) do
        post short_links_url,
             params: { short_link: { original_url: "https://example.com", publicly_visible: "1" }, guest_token: token }
      end
    end
    assert_equal true, ShortLink.last.publicly_visible
  end

  test "guest link defaults to hidden" do
    issued_at = Time.current
    token = @verifier.generate(
      guest_mode: true,
      issued_at: issued_at.to_i,
      expires_at: (issued_at + 30.minutes).to_i
    )
    GoogleSafeBrowsingService.stub(:safe_url?, true) do
      FetchShortLinkMetadataJob.stub(:perform_async, nil) do
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
      FetchShortLinkMetadataJob.stub(:perform_async, nil) do
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

  test "qr renders code image" do
    link = ShortLink.create!(original_url: "https://example.com")
    get qr_short_url(link.short_code)
    assert_response :success
    assert_equal "image/png", @response.media_type
  end

  test "redirect records ip from cloudflare header" do
    link = ShortLink.create!(original_url: "https://example.com")
    assert_difference("ShortLinkClick.count", 1) do
      get redirect_short_url(link.short_code), headers: { "CF-Connecting-IP" => "1.2.3.4" }
    end
    assert_equal "1.2.3.4", ShortLinkClick.last.ip
  end

end
