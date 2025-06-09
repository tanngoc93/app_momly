class AddPubliclyVisibleToShortLinks < ActiveRecord::Migration[7.0]
  def change
    add_column :short_links, :publicly_visible, :boolean, null: false, default: true
    add_index :short_links, :publicly_visible
  end
end
