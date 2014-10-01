class AddDisablePlaylistToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :disable_playlist, :boolean
  end
end
