class Withdrawal < ActiveRecord::Base
    attr_accessible :status, :amount, :sales_rep_id
end
