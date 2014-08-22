class AddShowingsToGrids < ActiveRecord::Migration
  def change
    add_column :grids, :title_bar, :boolean
    add_column :grids, :home_page, :boolean
  end
end
