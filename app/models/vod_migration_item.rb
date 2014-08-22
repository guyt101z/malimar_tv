class VodMigrationItem < ActiveRecord::Base
    attr_accessible :migration_id, :error, :status, :completed
end
