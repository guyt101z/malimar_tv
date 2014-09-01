class CreateMovieProgresses < ActiveRecord::Migration
  def change
    create_table :movie_progresses do |t|
      t.integer :user_id
      t.integer :movie_id
      t.integer :time

      t.timestamps
    end
  end
end
