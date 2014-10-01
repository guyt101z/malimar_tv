class AddUrlsToShows < ActiveRecord::Migration
  def change
    add_column :shows, :hls_url, :string
    add_column :shows, :rtmp_url, :string
  end
end
