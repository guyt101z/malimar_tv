class OrderNotification < ActiveRecord::Base
    attr_accessible :link, :message, :transaction_id
end
