class User < ApplicationRecord
  # == Devise modules ==
  # Others available:, :timeoutable
  # === Devise Modules ===
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable, :lockable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  # == Associations ==
  has_many :short_links, dependent: :destroy

  # === Validations ===
  validates :email,
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" },
            uniqueness: { case_sensitive: false, message: "has already been taken" },
            presence: true

  # == Callbacks ==
  before_create :generate_api_token

  # == Class Methods ==

  ## OAuth Authentication
  def self.find_or_create_from_omniauth(auth)
    user = find_by(email: auth.info.email)

    unless user
      user = create(
        email: auth.info.email,
        password: Devise.friendly_token[0, 20],
        name: auth.info.name
      )
    end

    user
  end

  # == Instance methods ==
  def reset_api_token!
    update!(api_token: generate_unique_api_token)
  end

  # == Private Methods ==
  private

  def generate_api_token
    self.api_token = generate_unique_api_token
  end

  def generate_unique_api_token
    loop do
      token = SecureRandom.hex(20)
      break token unless self.class.exists?(api_token: token)
    end
  end
end
