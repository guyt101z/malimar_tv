class CreateSeries < ActiveRecord::Migration
  def change
    create_table :series do |t|
      t.string :name
      t.integer :genre_id
      t.string :image
      t.timestamps
    end
  end
end
