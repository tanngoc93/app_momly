class CreateShortLinks < ActiveRecord::Migration[7.0]
  def change
    create_table :short_links do |t|
      t.string :original_url
      t.string :short_code
      t.integer :click_count
      t.references :user, null: false, foreign_key: true
      t.integer :post_id
      t.string :source
      t.string :plan_type

      t.timestamps
    end
    add_index :short_links, :short_code
  end
end
