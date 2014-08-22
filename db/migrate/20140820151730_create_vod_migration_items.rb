class CreateVodMigrationItems < ActiveRecord::Migration
  def change
    create_table :vod_migration_items do |t|
      t.string :error
      t.integer :migration_id
      t.boolean :completed
      t.string :status

      t.timestamps
    end
  end
end
