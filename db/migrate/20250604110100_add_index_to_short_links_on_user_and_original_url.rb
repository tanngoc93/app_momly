class AddIndexToShortLinksOnUserAndOriginalUrl < ActiveRecord::Migration[7.0]
  def change
    add_index :short_links, [:user_id, :original_url], name: 'index_short_links_on_user_and_original_url'
  end
end
