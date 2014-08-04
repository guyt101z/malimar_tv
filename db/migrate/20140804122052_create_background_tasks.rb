class CreateBackgroundTasks < ActiveRecord::Migration
  def change
    create_table :background_tasks do |t|
      t.string :name
      t.datetime :last_performed
      t.timestamps
    end
  end
end
