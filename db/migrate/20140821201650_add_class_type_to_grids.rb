class AddClassTypeToGrids < ActiveRecord::Migration
  def change
    add_column :grids, :class_type, :string
  end
end
