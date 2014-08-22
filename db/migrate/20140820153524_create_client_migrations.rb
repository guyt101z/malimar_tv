class CreateClientMigrations < ActiveRecord::Migration
  def change
    create_table :client_migrations do |t|

      t.timestamps
    end
  end
end
