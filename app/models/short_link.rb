class ShortLink < ApplicationRecord
  belongs_to :user

  validates :original_url, presence: true, format: URI::regexp(%w[http https])
  validates :short_code, presence: true, uniqueness: true

  before_validation :generate_short_code, on: :create

  private

  def generate_short_code
    self.short_code ||= loop do
      code = SecureRandom.alphanumeric(6).downcase
      break code unless ShortLink.exists?(short_code: code)
    end
  end
end
