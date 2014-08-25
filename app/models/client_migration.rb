class ClientMigration < ActiveRecord::Base
    mount_uploader :file, MigrationUploader
end
