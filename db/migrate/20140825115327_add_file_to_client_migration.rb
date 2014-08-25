class AddFileToClientMigration < ActiveRecord::Migration
  def change
    add_column :client_migrations, :file, :string
  end
end
