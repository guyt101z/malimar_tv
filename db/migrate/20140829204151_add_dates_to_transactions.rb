class AddDatesToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :start, :date
    add_column :transactions, :end, :date
  end
end
