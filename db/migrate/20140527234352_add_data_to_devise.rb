class AddDataToDevise < ActiveRecord::Migration
  def change
  	add_column :users, :first_name, :string
  	add_column :users, :last_name, :string
  	add_column :users, :address_1, :string
  	add_column :users, :address_2, :string
  	add_column :users, :city, :string
  	add_column :users, :state, :string
  	add_column :users, :country, :string
  	
  	add_column :sales_representatives, :first_name, :string
  	add_column :sales_representatives, :last_name, :string
  	add_column :sales_representatives, :address_1, :string
  	add_column :sales_representatives, :address_2, :string
  	add_column :sales_representatives, :city, :string
  	add_column :sales_representatives, :state, :string
  	add_column :sales_representatives, :country, :string
  	
  	add_column :admins, :first_name, :string
  	add_column :admins, :last_name, :string
  	
  end
end
