class Movie < ActiveRecord::Base
	attr_accessible :name, :rating_id, :genre_id, :image, :url
	
	mount_uploader :image, MovieImageUploader
	
	validates_presence_of :name, :genre_id, :url
end
