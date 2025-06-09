require "test_helper"

class ShortLinkTest < ActiveSupport::TestCase
  test "valid factory" do
    link = ShortLink.new(original_url: "https://example.com")
    assert link.valid?
    assert_match(/[a-z0-9]{6}/, link.short_code)
  end

  test "original_url must be present" do
    link = ShortLink.new(original_url: nil)
    assert link.invalid?
    assert_includes link.errors[:original_url], "can't be blank"
  end

  test "original_url must be http or https" do
    link = ShortLink.new(original_url: "ftp://example.com")
    assert link.invalid?
    assert_includes link.errors[:original_url], "is invalid"
  end

  test "short_code must be unique" do
    existing = ShortLink.create!(original_url: "https://example.com", short_code: "abc123")
    link = ShortLink.new(original_url: "https://example.org", short_code: "abc123")
    assert link.invalid?
    assert_includes link.errors[:short_code], "has already been taken"
  end

  test "generate_short_code generates unique code" do
    ShortLink.create!(original_url: "https://example.com", short_code: "abc123")
    codes = %w[abc123 def456]
    SecureRandom.stub :alphanumeric, ->(n) { codes.shift } do
      link = ShortLink.new(original_url: "https://example.org")
      link.validate
      assert_equal "def456", link.short_code
    end
  end
end
