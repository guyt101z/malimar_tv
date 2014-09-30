class CreateGridItems < ActiveRecord::Migration
  def change
    create_table :grid_items do |t|
      t.integer :video_id
      t.string :video_type
      t.integer :grid_id

      t.timestamps
    end
  end
end
