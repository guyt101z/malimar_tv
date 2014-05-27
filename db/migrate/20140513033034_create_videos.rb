class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.integer :vid_file_id
      t.boolean :premium
      t.integer :rating_id
      t.datetime :release_date
      t.timestamps
    end
  end
end
