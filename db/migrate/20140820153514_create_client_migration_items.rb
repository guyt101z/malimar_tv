class CreateClientMigrationItems < ActiveRecord::Migration
  def change
    create_table :client_migration_items do |t|
      t.string :error
      t.integer :migration_id
      t.boolean :completed
      t.string :status

      t.timestamps
    end
  end
end
