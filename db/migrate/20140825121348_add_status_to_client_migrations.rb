class AddStatusToClientMigrations < ActiveRecord::Migration
  def change
      add_column :client_migrations, :status, :boolean
  end
end
