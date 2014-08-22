class AddFileToGrid < ActiveRecord::Migration
  def change
    add_column :grids, :file, :string
  end
end
