class AddCompanyToSalesRepresentative < ActiveRecord::Migration
  def change
    add_column :sales_representatives, :company, :string
  end
end
