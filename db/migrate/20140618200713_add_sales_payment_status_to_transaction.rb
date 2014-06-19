class AddSalesPaymentStatusToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :payment_status, :string
  end
end
