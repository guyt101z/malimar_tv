class AddWeightToGrid < ActiveRecord::Migration
  def change
    add_column :grids, :weight, :integer
  end
end
