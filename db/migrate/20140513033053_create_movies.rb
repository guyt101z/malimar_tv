class CreateMovies < ActiveRecord::Migration
  def change
    create_table :movies do |t|
      t.string :name
      t.integer :video_id
      t.integer :genre_id
      t.string :image
      t.timestamps
    end
  end
end
