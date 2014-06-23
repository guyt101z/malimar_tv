class SupportMessage < ActiveRecord::Base
	attr_accessible :admin_id, :user_id, :sales_representative_id, :support_case_id, :message

	validates_presence_of :message
end
