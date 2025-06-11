class Page < ApplicationRecord
  before_validation :generate_slug

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true

  private

  def generate_slug
    self.slug = title.to_s.parameterize if slug.blank? && title.present?
  end
end
