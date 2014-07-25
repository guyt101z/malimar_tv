class CreateRepNotifications < ActiveRecord::Migration
  def change
    create_table :rep_notifications do |t|
      t.integer :sales_rep_id
      t.string :message
      t.string :notif_type
      t.string :message
      t.date :expires
      t.boolean :viewed
      t.timestamps
    end

    # Update other notification types
    add_column :admin_notifications, :viewed, :boolean
    add_column :admin_notifications, :notif_type, :string
    remove_column :admin_notifications, :read
    remove_column :admin_notifications, :type


    add_column :user_notifications, :viewed, :boolean
    add_column :user_notifications, :notif_type, :string
    remove_column :user_notifications, :read
    remove_column :user_notifications, :type
  end
end
