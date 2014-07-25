class AddPaypalEmailToSalesRepresentative < ActiveRecord::Migration
  def change
    add_column :sales_representatives, :paypal, :string
  end
end
