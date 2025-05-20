class AllowNullUserIdInShortLinks < ActiveRecord::Migration[7.0]
  def change
    change_column_null :short_links, :user_id, true
  end
end
