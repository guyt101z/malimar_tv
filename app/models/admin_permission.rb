class AdminPermission < ActiveRecord::Base
    attr_accessible :permission, :level
end
