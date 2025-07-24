class Page < ApplicationRecord
  SLUG_FORMAT = /\A[a-z0-9\-]+\z/i.freeze
  ALLOWED_TAGS = %w[p br strong em a ul ol li h1 h2 h3 h4 h5 h6 blockquote].freeze
  ALLOWED_ATTRIBUTES = %w[href].freeze

  before_validation :generate_slug
  before_save :sanitize_content

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true, format: { with: SLUG_FORMAT }

  # Ransack configuration
  def self.ransackable_attributes(auth_object = nil)
    %w[content_html created_at id meta_description meta_title slug title updated_at]
  end

  private

  def generate_slug
    self.slug = title.to_s.parameterize if slug.blank? && title.present?
  end

  def sanitize_content
    return unless content_html.present?

    self.content_html = ActionController::Base.helpers.sanitize(
      content_html,
      tags: ALLOWED_TAGS,
      attributes: ALLOWED_ATTRIBUTES
    )
  end
end
