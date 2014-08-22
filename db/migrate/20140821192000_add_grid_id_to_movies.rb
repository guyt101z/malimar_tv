class AddGridIdToMovies < ActiveRecord::Migration
  def change
    add_column :movies, :grid_id, :integer
  end
end
