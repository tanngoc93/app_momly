ActiveAdmin.register Page do
  menu priority: 3
  permit_params :title, :slug, :content_html, :meta_title, :meta_description

  index do
    selectable_column
    id_column
    column :title
    column :slug do |page|
      link_to "/pages/#{page.slug}", page_path(page.slug), target: '_blank'
    end
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :title
      row :slug do |page|
        link_to "/pages/#{page.slug}", page_path(page.slug), target: '_blank'
      end
      row :content_html do |page|
        pre page.content_html
      end
      row :meta_title
      row :meta_description
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :title
      f.input :slug,
              hint: 'Optional, leave blank to use a slug based on the title. Final URL will be /pages/your-slug'
      f.input :content_html,
              as: :text,
              input_html: { rows: 15 },
              hint: 'HTML content for the page body'
      f.input :meta_title
      f.input :meta_description
    end
    f.actions
  end
end
