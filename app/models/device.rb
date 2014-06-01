class Device < ActiveRecord::Base
	attr_accessible :serial, :user_id, :type
	validates_presence_of :serial, :user_id, :type
	validates_uniqueness_of :serial, :scope => :type
end
