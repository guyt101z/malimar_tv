class AddFreeToGrids < ActiveRecord::Migration
  def change
    add_column :grids, :free, :boolean
  end
end
