class Device < ActiveRecord::Base
	attr_accessible :serial, :user_id, :type, :name, :expiry, :serial_file, :adult
	validates_presence_of :serial, :user_id, :type
	validates_uniqueness_of :serial, :scope => :type


	mount_uploader :serial_file, SerialUploader

	def humanized_type
		case type
		when 'Roku'
			return 'Roku'
		when 'Ipad'
			return 'iPad'
		when 'Iphone'
			return 'iPhone'
		when 'Ipod'
			return 'iPod'
		when 'Android'
			return 'Android'
		else
			return 'Unrecognized '+type
		end
	end

	def nickname(with_type)
		if with_type
			return "#{name} (#{humanized_type})"
		else
			return name
		end
	end

	def premium?
		if type == 'Roku'
			if start_date.present? && expiry.present?
				return start_date <= Date.today && expiry >= Date.today
			else
				return false
			end
		else
			user = User.where(id: user_id).first
			unless user.nil?
				if user.start_date.present? && user.expiry.present?
					return user.start_date <= Date.today && user.expiry >= Date.today
				else
					return false
				end
			else
				return false
			end
		end
	end
	def status
		unless premium?
			return 'Free'
		else
			return "Premium (until #{expiry.strftime('%Y/%m/%d')})"
		end
	end

	def expired?
		if type == 'Roku'
			if Transaction.where(user_id: id, roku_id: id, status: ['Paid','Refunded']).any? && premium? == false
				return true
			else
				return false
			end
		else
			if expiry.nil? || expiry < Date.today
				return true
			else
				return false
			end
		end
	end
end
