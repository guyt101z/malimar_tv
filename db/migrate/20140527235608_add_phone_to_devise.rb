class AddPhoneToDevise < ActiveRecord::Migration
  def change
  	add_column :users, :phone, :string
  	
  	add_column :sales_representatives, :phone, :string
  end
end
