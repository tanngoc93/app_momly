require "test_helper"

class PageTest < ActiveSupport::TestCase
  test "slug format validation" do
    page = Page.new(title: "Hello", slug: "bad slug")
    assert page.invalid?
    assert_includes page.errors[:slug], "is invalid"

    page.slug = "good-slug"
    assert page.valid?
  end

  test "content is sanitized" do
    raw_html = "<script>alert('x')</script><p>Ok</p>"
    page = Page.create!(title: "Title", slug: "title", content_html: raw_html)
    assert_equal "<p>Ok</p>", page.content_html
  end
end

