require "test_helper"
require "fileutils"

class SitemapGeneratorTest < ActiveSupport::TestCase
  test "generates sitemap and robots files" do
    Rails.application.config.momly_domains = ["example.com"]
    Page.create!(title: "About", slug: "about", content_html: "<p>Hi</p>")

    original_robots = File.read(Rails.root.join("public", "robots.txt")) if File.exist?(Rails.root.join("public", "robots.txt"))

    SitemapGenerator.generate

    xml = File.read(Rails.root.join("public", "sitemap.xml"))
    assert_includes xml, "https://example.com/pages/about"

    robots = File.read(Rails.root.join("public", "robots.txt"))
    assert_includes robots, "Sitemap: https://example.com/sitemap.xml"
  ensure
    FileUtils.rm_f Rails.root.join("public", "sitemap.xml")
    File.write(Rails.root.join("public", "robots.txt"), original_robots || "")
  end
end
