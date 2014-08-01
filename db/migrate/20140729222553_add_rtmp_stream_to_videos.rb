class AddRtmpStreamToVideos < ActiveRecord::Migration
  def change
    add_column :channels, :rtmp_url, :string
    add_column :episodes, :rtmp_url, :string
    add_column :movies, :rtmp_url, :string
  end
end
