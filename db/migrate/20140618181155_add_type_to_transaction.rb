class AddTypeToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :payment_type, :string
  end
end
