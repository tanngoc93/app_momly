# frozen_string_literal: true
ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    columns do
      column do
        panel "Recent Users" do
          ul do
            User.order(created_at: :desc).limit(5).map do |user|
              li link_to(user.email, admin_user_path(user))
            end
          end
        end
      end

      column do
        panel "Recent Short Links" do
          ul do
            ShortLink.order(created_at: :desc).limit(5).map do |link|
              li link_to(link.short_code, admin_short_link_path(link))
            end
          end
        end
      end
    end
  end
end
