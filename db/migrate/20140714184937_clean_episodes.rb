class CleanEpisodes < ActiveRecord::Migration
  def change
      remove_column :episodes, :content_type
      remove_column :episodes, :content_quality
      remove_column :episodes, :stream_format
      remove_column :episodes, :bitrate
      remove_column :episodes, :stream_quality
      remove_column :episodes, :hd
      add_column :channels, :bitrate, :string
      add_column :movies, :bitrate, :string
      add_column :shows, :bitrate, :string
      add_column :shows, :content_quality, :string
      add_column :shows, :content_type, :string
  end
end
