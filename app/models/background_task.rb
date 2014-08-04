class BackgroundTask < ActiveRecord::Base
    attr_accessible :name, :error, :last_performed
end
