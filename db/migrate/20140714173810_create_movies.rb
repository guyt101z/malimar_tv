class CreateMovies < ActiveRecord::Migration
  def change
    create_table :movies do |t|
      t.string :name
      t.string :image
      t.boolean :roku
      t.boolean :ios
      t.boolean :android
      t.boolean :web
      t.string :stream_url
      t.text :genres
      t.text :actors
      t.boolean :free
      t.timestamps
    end
  end
end
