class Page < ApplicationRecord
  before_validation :generate_slug

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true

  # Ransack configuration
  def self.ransackable_attributes(auth_object = nil)
    %w[content_html created_at id meta_description meta_title slug title updated_at]
  end

  private

  def generate_slug
    self.slug = title.to_s.parameterize if slug.blank? && title.present?
  end
end
