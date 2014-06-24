class AddCustomerRefundedToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :customer_refunded, :datetime
  end
end
