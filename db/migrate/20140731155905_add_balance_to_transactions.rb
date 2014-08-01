class AddBalanceToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :balance_used, :float
  end
end
