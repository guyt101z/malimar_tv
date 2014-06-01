class Transaction < ActiveRecord::Base
	attr_accessible :user_id, :sales_rep_id, :product_details
end
