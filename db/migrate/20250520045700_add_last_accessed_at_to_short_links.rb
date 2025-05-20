class AddLastAccessedAtToShortLinks < ActiveRecord::Migration[7.0]
  def change
    add_column :short_links, :last_accessed_at, :datetime
  end
end
