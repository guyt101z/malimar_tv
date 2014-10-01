class AddDisablePlaylistToMovies < ActiveRecord::Migration
  def change
    add_column :movies, :disable_playlist, :boolean
  end
end
