class ChangePubliclyVisibleNull < ActiveRecord::Migration[7.0]
  def change
    change_column_null :short_links, :publicly_visible, true
  end
end
