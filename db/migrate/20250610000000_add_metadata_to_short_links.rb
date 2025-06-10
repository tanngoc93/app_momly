class AddMetadataToShortLinks < ActiveRecord::Migration[7.0]
  def change
    add_column :short_links, :page_title, :string
    add_column :short_links, :meta_description, :text
  end
end
