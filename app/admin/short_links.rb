ActiveAdmin.register ShortLink do
  menu priority: 3
  permit_params :original_url, :short_code, :user_id, :publicly_visible

  scope :all, default: true
  scope :guest_links
  scope "User Links" do |links|
    links.where.not(user_id: nil)
  end

  filter :user
  filter :short_code
  filter :created_at

  index do
    selectable_column
    id_column
    column :short_code
    column :original_url
    column :user
    column :click_count
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :short_code
      row :original_url
      row :user
      row :click_count
      row :created_at
      row :updated_at
    end

    panel "Click Statistics" do
      table_for short_link.short_link_clicks.order(created_at: :desc) do
        column :id
        column :ip
        column :referrer
        column :user_agent
        column :created_at
      end
    end
  end
end
