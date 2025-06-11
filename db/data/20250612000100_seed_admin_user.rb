class SeedAdminUser < SeedMigration::Migration
  def up
    AdminUser.find_or_create_by!(email: ENV.fetch('ADMIN_EMAIL', 'admin@example.com')) do |user|
      user.password = ENV.fetch('ADMIN_PASSWORD', 'password')
      user.password_confirmation = ENV.fetch('ADMIN_PASSWORD', 'password')
    end
  end

  def down
    AdminUser.find_by(email: ENV.fetch('ADMIN_EMAIL', 'admin@example.com'))&.destroy
  end
end
