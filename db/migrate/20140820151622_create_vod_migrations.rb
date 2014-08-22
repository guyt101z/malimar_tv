class CreateVodMigrations < ActiveRecord::Migration
  def change
    create_table :vod_migrations do |t|

      t.timestamps
    end
  end
end
