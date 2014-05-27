class VideosController < ApplicationController
	def index
		
	end
	
	def search_suggestions
		if params[:search].present?
			if params[:search].empty?
				@empty = true
			else
				@empty = false
				m = Movie.arel_table
				@movies = Movie.where(m[:name].matches(params[:search]+'%'))
				if params[:genre].present?
					@movies = @movies.where(m[:genre_id].matches(params[:genre]))
				end
			end
		else
			@empty = true
		end
	end
end
