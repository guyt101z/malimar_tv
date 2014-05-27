class CreateAdminNotifications < ActiveRecord::Migration
  def change
    create_table :admin_notifications do |t|
      t.integer :admin_id
      t.string :type
      t.string :message
      t.datetime :expiry
      t.boolean :read
      t.timestamps
    end
  end
end
