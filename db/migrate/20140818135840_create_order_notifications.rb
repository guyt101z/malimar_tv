class CreateOrderNotifications < ActiveRecord::Migration
  def change
    create_table :order_notifications do |t|
      t.string :message
      t.integer :transaction_id
      t.string :message
      t.boolean :link

      t.timestamps
    end
  end
end
