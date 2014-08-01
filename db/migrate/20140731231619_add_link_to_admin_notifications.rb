class AddLinkToAdminNotifications < ActiveRecord::Migration
  def change
    add_column :admin_notifications, :link, :string
  end
end
