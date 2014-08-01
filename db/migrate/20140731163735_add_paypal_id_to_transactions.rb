class AddPaypalIdToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :paypal_id, :string
  end
end
