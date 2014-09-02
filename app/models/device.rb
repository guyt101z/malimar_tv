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
			return Transaction.where(user_id: id, roku_id: id, status: ['Paid','Refunded']).where('? <= ?', :start, Date.today).where('? <= ?', Date.today, :end).any?
		else
			return Transaction.where(user_id: id, roku_id: nil, status: ['Paid','Refunded']).where('? <= ?', :start, Date.today).where('? <= ?', Date.today, :end).any?
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
		if device.expiry.nil?
			return true
		else
			return expiry < Date.today
		end
	end
end
