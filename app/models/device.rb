class Device < ActiveRecord::Base
	attr_accessible :serial, :user_id, :type, :name, :expiry, :serial_file
	validates_presence_of :serial, :user_id, :type
	validates_uniqueness_of :serial, :scope => :type
	validates_length_of :serial, minimum: 12, maximum: 13, message: 'is not valid'

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
end
