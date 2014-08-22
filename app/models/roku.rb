class Roku < Device
	attr_accessible :serial, :user_id
	validates_length_of :serial, minimum: 12, maximum: 13, message: 'is not valid'

	def status
		if expiry.nil? || expiry < Date.today
			return 'Free'
		else
			return "Premium (until #{expiry.strftime('%Y/%m/%d')})"
		end
	end
end
