class AddPlanIdToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :plan_id, :integer
  end
end
