class ChangeClickCountDefaultInShortLinks < ActiveRecord::Migration[7.0]
  def change
    change_column_default :short_links, :click_count, from: nil, to: 0
    # Optional: update existing nulls to 0
    ShortLink.where(click_count: nil).update_all(click_count: 0)
  end
end
