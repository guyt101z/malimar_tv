class CreateBrokenLinks < ActiveRecord::Migration
  def change
    create_table :broken_links do |t|
      t.integer :video_id
      t.string :video_type
      t.integer :user_id

      t.timestamps
    end
  end
end
