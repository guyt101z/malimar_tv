class Plan < ActiveRecord::Base
	attr_accessible :name, :price, :months, :features
end
