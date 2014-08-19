class AddPaymentMethodToWithdrawals < ActiveRecord::Migration
  def change
    add_column :withdrawals, :payment_method, :string
  end
end
