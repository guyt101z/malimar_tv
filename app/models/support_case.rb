class SupportCase < ActiveRecord::Base
	attr_accessible :user_id, :sales_representative_id, :admin_id, :issue_description, :priority, :category, :title

	validates_presence_of :issue_description, :priority, :category, :title

	def matches_search?(search_term)

	end
end
