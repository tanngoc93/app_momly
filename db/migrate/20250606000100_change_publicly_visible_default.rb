class ChangePubliclyVisibleDefault < ActiveRecord::Migration[7.0]
  def change
    change_column_default :short_links, :publicly_visible, from: true, to: false
  end
end
