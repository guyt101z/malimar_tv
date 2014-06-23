class AddUpdateDatesToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :customer_paid, :datetime
    add_column :transactions, :sales_rep_paid, :datetime
  end
end
