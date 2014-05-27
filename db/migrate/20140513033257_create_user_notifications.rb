class CreateUserNotifications < ActiveRecord::Migration
  def change
    create_table :user_notifications do |t|
      t.integer :user_id
      t.string :type
      t.string :message
      t.datetime :expiry
      t.boolean :read
      t.timestamps
    end
  end
end
