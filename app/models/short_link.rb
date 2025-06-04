class ShortLink < ApplicationRecord
  # == Associations ==
  belongs_to :user, optional: true

  # == Enums ==
  enum source: {
    web: "web",
    api: "api"
  }, _prefix: :source

  # == Validations ==
  validates :original_url, presence: true, format: URI::regexp(%w[http https])
  validates :short_code, presence: true, uniqueness: true

  # == Callbacks ==
  before_validation :generate_short_code, on: :create

  # == Instance methods ==
  def created_via
    source.presence || "web"
  end

  def days_alive
    return 0 unless created_at

    (Time.current.to_date - created_at.to_date).to_i
  end

  # == Private Methods ==
  private

  def generate_short_code
    self.short_code ||= loop do
      code = SecureRandom.alphanumeric(6).downcase
      break code unless ShortLink.exists?(short_code: code)
    end
  end
end
