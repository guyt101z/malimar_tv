class AddArraysToGrids < ActiveRecord::Migration
  def change
    add_column :grids, :items, :text
    add_column :grids, :grids, :text
  end
end
