class User < ApplicationRecord
  # == Devise modules ==
  # Others available: :confirmable, :lockable, :timeoutable, :trackable, :omniauthable
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable

  # == Associations ==
  has_many :short_links, dependent: :destroy

  # == Callbacks ==
  before_create :generate_api_token

  # == Instance methods ==
  private

  def generate_api_token
    self.api_token = SecureRandom.hex(20)
  end
end
