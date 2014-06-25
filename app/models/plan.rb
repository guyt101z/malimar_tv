class Plan < ActiveRecord::Base
	attr_accessible :name, :price, :months, :features

	validates_presence_of :name, :price, :months
end
