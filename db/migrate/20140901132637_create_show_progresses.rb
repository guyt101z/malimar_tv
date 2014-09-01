class CreateShowProgresses < ActiveRecord::Migration
  def change
    create_table :show_progresses do |t|
      t.integer :user_id
      t.integer :show_id
      t.integer :episode_number

      t.timestamps
    end
  end
end
