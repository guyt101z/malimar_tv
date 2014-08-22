class AddGridIdToShows < ActiveRecord::Migration
  def change
    add_column :shows, :grid_id, :integer
  end
end
