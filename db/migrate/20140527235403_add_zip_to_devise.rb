class AddZipToDevise < ActiveRecord::Migration
  def change
  	add_column :users, :zip, :string
  	
  	add_column :sales_representatives, :zip, :string
  end
end
