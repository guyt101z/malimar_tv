class CreateEpisodes < ActiveRecord::Migration
  def change
    create_table :episodes do |t|
      t.string :name
      t.integer :episode_number
      t.integer :video_id
      t.integer :season_id
      t.timestamps
    end
  end
end
