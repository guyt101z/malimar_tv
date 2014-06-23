class AdminActivity < ActiveRecord::Base
	attr_accessible :admin_id, :data

	validates_presence_of :admin_id, :data

	def test
		
	end
end
