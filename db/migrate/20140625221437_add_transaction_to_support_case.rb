class AddTransactionToSupportCase < ActiveRecord::Migration
  def change
    add_column :support_cases, :transaction_id, :integer
  end
end
