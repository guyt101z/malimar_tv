class RemoveGridArrays < ActiveRecord::Migration
  def change
      remove_column :grids, :items
      remove_column :grids, :grids
  end
end
