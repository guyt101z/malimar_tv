class SupportCase < ActiveRecord::Base
	attr_accessible :user_id, :sales_representative_id, :admin_id, :issue_description, :priority, :category, :title, :transaction_id

	validates_presence_of :issue_description, :priority, :category, :title

	def matches_search?(search_term)

	end

	def self.update_daily_data(today)
		data = DailyData.where(date: today).last

		unless data.nil?
			data.opened_tickets = SupportCase.where(opened: today).count
			data.closed_tickets = SupportCase.where(closed: today).count
			data.archived_tickets = SupportCase.where(archived: today).count
			data.new_tickets = SupportCase.where(created_at: today.beginning_of_day..today.end_of_day).count
			data.save
		end
	end

	def user_name
		if user_id.nil?
			rep = SalesRepresentative.where(id: sales_representative_id).first
			if rep.nil?
				return 'Not Found'
			else
				return "#{rep.name} (Rep)"
			end
		elsif sales_representative_id.nil?
			user = User.where(id: user_id).first
			if user.nil?
				return 'Not Found'
			else
				return "#{user.name} (Client)"
			end
		else
			return 'Not Found'
		end
	end

	def moves
		return SupportMessage.where(support_case_id: id).count
	end
end
