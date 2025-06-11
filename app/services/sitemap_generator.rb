class SitemapGenerator
  def self.generate
    new.generate
  end

  def generate
    host = Rails.application.config.momly_domains.first
    helpers = Rails.application.routes.url_helpers

    urls = []
    urls << helpers.root_url(host: host)

    Page.where.not(content_html: [nil, '']).find_each do |page|
      urls << helpers.page_url(page.slug, host: host)
    end

    xml = build_xml(urls)
    File.write(Rails.root.join('public', 'sitemap.xml'), xml)

    robots = "User-agent: *\nAllow: /\nSitemap: https://#{host}/sitemap.xml\n"
    File.write(Rails.root.join('public', 'robots.txt'), robots)
  end

  private

  def build_xml(urls)
    Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
      xml.urlset(xmlns: 'http://www.sitemaps.org/schemas/sitemap/0.9') do
        urls.each do |url|
          xml.url { xml.loc url }
        end
      end
    end.to_xml
  end
end
