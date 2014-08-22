class ClientMigrationItem < ActiveRecord::Base
    attr_accessible :migration_id, :error, :status, :completed
end
