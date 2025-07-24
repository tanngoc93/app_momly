class CreatePages < ActiveRecord::Migration[7.0]
  def change
    create_table :pages do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.text :content_html
      t.string :meta_title
      t.text :meta_description

      t.timestamps
    end

    add_index :pages, :slug, unique: true
  end
end
