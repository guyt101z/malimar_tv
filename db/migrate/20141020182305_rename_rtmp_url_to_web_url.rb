class RenameRtmpUrlToWebUrl < ActiveRecord::Migration
  def change
  	rename_column :channels, :rtmp_url, :web_url
  	rename_column :movies, :rtmp_url, :web_url
  	rename_column :shows, :rtmp_url, :web_url

  	add_column :channels, :use_web_url, :boolean
  	add_column :movies, :use_web_url, :boolean
  	add_column :shows, :use_web_url, :boolean
  end
end
