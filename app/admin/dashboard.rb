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
          table_for ShortLink.order(created_at: :desc).limit(50) do
            column "Short URL" do |link|
              link_to redirect_short_url(link.short_code), redirect_short_url(link.short_code), target: "_blank"
            end
            column "Creator" do |link|
              link.user ? link.user.email : "Guest"
            end
          end
        end
      end
    end
  end
end
