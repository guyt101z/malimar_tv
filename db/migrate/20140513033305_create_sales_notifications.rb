class CreateSalesNotifications < ActiveRecord::Migration
  def change
    create_table :sales_notifications do |t|
      t.integer :sales_rep_id
      t.string :type
      t.string :message
      t.datetime :expiry
      t.boolean :read
      t.timestamps
    end
  end
end
