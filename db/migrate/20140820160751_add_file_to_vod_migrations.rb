class AddFileToVodMigrations < ActiveRecord::Migration
  def change
    add_column :vod_migrations, :file, :string
  end
end
