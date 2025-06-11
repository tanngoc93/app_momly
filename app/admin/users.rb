ActiveAdmin.register User do
  index do
    selectable_column
    id_column
    column :email
    column :name
    column :created_at
    column("Links") { |u| u.short_links.count }
    actions
  end

  show do
    attributes_table do
      row :id
      row :email
      row :name
      row :created_at
    end

    panel "Short Links" do
      table_for user.short_links.order(created_at: :desc) do
        column :short_code
        column :original_url
        column :click_count
        column :created_at
        column :last_accessed_at
        column("Stats") { |link| link_to "View", stats_short_link_path(link) }
      end
    end
  end
end
