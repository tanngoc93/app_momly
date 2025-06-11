ActiveAdmin.register Page do
  menu priority: 5
  permit_params :title, :slug, :content_html, :meta_title, :meta_description

  index do
    selectable_column
    id_column
    column :title
    column :slug
    column :created_at
    actions
  end

  form do |f|
    f.inputs do
      f.input :title
      f.input :slug, hint: '/pages/your-slug'
      f.input :content_html, as: :text, input_html: { rows: 15 }
      f.input :meta_title
      f.input :meta_description
    end
    f.actions
  end
end
