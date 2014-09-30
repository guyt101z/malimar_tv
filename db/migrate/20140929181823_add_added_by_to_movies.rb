class AddAddedByToMovies < ActiveRecord::Migration
  def change
    add_column :movies, :added_by, :integer
    add_column :movies, :edited_by, :integer
  end
end
