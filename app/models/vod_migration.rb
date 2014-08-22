class VodMigration < ActiveRecord::Base
    attr_accessible :file

    validates_presence_of :file

    mount_uploader :file, MigrationUploader
end
