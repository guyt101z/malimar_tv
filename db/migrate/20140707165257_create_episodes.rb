class CreateEpisodes < ActiveRecord::Migration
  def change
    create_table :episodes do |t|
      t.string :video_id
      t.string :title
      t.integer :episode_number
      t.date :release_date
      t.string :content_type
      t.string :content_quality
      t.string :stream_format
      t.string :bitrate
      t.string :stream_quality
      t.string :stream_url
      t.boolean :hd
      t.text :actors    # Serialized array
      t.text :genres    # Serialized array
      t.string :synopsis
      t.integer :channel_id
      t.timestamps
    end
  end
end
