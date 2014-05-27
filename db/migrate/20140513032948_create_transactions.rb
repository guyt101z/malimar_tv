class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.integer :user_id
      t.integer :roku_id
      t.integer :sales_rep_id
      t.text :product_details
      
      t.timestamps
    end
  end
end
