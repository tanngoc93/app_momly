class CreateShortLinkClicks < ActiveRecord::Migration[7.0]
  def change
    create_table :short_link_clicks do |t|
      t.references :short_link, null: false, foreign_key: true
      t.string :ip
      t.string :referrer
      t.string :user_agent
      t.timestamps
    end
    add_index :short_link_clicks, :created_at
  end
end
