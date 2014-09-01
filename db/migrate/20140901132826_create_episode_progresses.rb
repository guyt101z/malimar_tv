class CreateEpisodeProgresses < ActiveRecord::Migration
  def change
    create_table :episode_progresses do |t|
      t.integer :episode_id
      t.integer :time

      t.timestamps
    end
  end
end
