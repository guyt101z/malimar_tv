class Movie < ActiveRecord::Base
	attr_accessible :name, :rating_id, :genre_id, :image
end
