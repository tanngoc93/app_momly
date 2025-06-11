ActiveAdmin.register User do
  menu priority: 4
  permit_params :email, :password, :password_confirmation, :name

  index do
    selectable_column
    id_column
    column :email
    column :name
    column :created_at
    column "Links" do |user|
      link_to "View", admin_short_links_path(q: { user_id_eq: user.id })
    end
    actions
  end

  filter :email
  filter :created_at

  show do
    attributes_table do
      row :id
      row :email
      row :name
      row :created_at
      row :updated_at
    end

    panel "Short Links" do
      table_for user.short_links do
        column :id
        column :short_code
        column :original_url
        column :click_count
        column :created_at
      end
    end
  end
end
