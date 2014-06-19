class AddCommissionToSalesRepresentative < ActiveRecord::Migration
  def change
    add_column :sales_representatives, :account_balance, :float
    add_column :sales_representatives, :commission_rate, :float
  end
end
