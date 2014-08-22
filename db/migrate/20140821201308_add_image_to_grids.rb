class AddImageToGrids < ActiveRecord::Migration
  def change
    add_column :grids, :image, :string
  end
end
