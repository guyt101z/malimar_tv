class AddPhotoToDevise < ActiveRecord::Migration
  def change
  	add_column :users, :photo, :string
  	
  	add_column :sales_representatives, :photo, :string
  end
end
