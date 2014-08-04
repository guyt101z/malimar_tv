class SystemLog < ActiveRecord::Base
    attr_accessible :title, :error, :message
end
