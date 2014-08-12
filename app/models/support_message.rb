class SupportMessage < ActiveRecord::Base
	attr_accessible :admin_id, :user_id, :sales_representative_id, :support_case_id, :message

	validates_presence_of :message

	def user_name
		if admin_id.present?
			admin = Admin.where(id: admin_id).first
			if admin.nil?
				return 'Admin'
			else
				return admin.name
			end
		elsif user_id.present?
			user = User.where(id: user_id).first
			if user.nil?
				return 'User'
			else
				return user.name
			end
		elsif sales_representative_id.present?
			rep = SalesRepresentative.where(id: sales_representative_id).first
			if rep.nil?
				return 'Rep'
			else
				return rep.name
			end
		end
	end
end
