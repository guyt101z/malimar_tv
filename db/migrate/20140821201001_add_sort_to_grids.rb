class AddSortToGrids < ActiveRecord::Migration
  def change
    add_column :grids, :sort, :string
  end
end
