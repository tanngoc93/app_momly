class AddUniqueIndexToShortLinksShortCode < ActiveRecord::Migration[7.0]
  def change
    add_index :short_links, :short_code, unique: true, name: 'index_short_links_on_short_code_unique'
  end
end
