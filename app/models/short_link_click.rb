class ShortLinkClick < ApplicationRecord
  belongs_to :short_link

  # Ransack configuration
  def self.ransackable_attributes(auth_object = nil)
    %w[id short_link_id ip referrer user_agent created_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[short_link]
  end
end
