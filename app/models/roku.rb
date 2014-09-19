class Roku < Device
	attr_accessible :serial, :user_id
	validates_length_of :serial, minimum: 12, maximum: 12, message: 'is not valid'


end
