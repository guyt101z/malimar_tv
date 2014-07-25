class CreateWithdrawals < ActiveRecord::Migration
  def change
    create_table :withdrawals do |t|
      t.integer :sales_rep_id
      t.float :amount
      t.string :status
      t.integer :admin_id
      t.timestamps
    end
  end
end
