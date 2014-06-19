class Transaction < ActiveRecord::Base
	attr_accessible :user_id, :roku_id, :status, :payment_type, :sales_rep_id, :product_details

	validates_presence_of :user_id, :status, :payment_type, :product_details
end
