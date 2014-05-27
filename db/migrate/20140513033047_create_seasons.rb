class CreateSeasons < ActiveRecord::Migration
  def change
    create_table :seasons do |t|
      t.integer :series_id
      t.integer :season_number
      t.timestamps
    end
  end
end
