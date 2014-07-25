class AddApprovalDateToWithdrawals < ActiveRecord::Migration
  def change
    add_column :withdrawals, :approved, :datetime
  end
end
