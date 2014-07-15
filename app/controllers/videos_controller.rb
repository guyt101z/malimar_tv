class VideosController < ApplicationController

	# Channel Methods
	#######################################################################################

	def view_channel
		@channel = Channel.find(params[:id])
	end

	def add_channel
		@channel = Channel.new
		@channel.name = params[:new_name]
		@channel.roku = params[:new_roku]
		@channel.ios = params[:new_ios]
		@channel.android = params[:new_android]
		@channel.web = params[:new_web]
		@channel.free = params[:new_free]
		@channel.stream_url = params[:new_stream_url]
		@channel.content_type = params[:new_content_type]
		@channel.content_quality = params[:new_content_quality]
		@channel.bitrate = params[:new_bitrate]
		@channel.synopsis = params[:new_synopsis]
		@channel.genres = params[:new_genres]
		@channel.actors = params[:new_actors]
		@channel.save
	end

	def update_channel
		@channel = Channel.find(params[:id])
		@channel.name = params[:name]
		@channel.roku = params[:roku]
		@channel.ios = params[:ios]
		@channel.android = params[:android]
		@channel.web = params[:web]
		@channel.free = params[:free]
		@channel.stream_url = params[:stream_url]
		@channel.content_type = params[:content_type]
		@channel.content_quality = params[:content_quality]
		@channel.bitrate = params[:bitrate]
		@channel.synopsis = params[:synopsis]
		@channel.genres = params[:genres]
		@channel.actors = params[:actors]
		@channel.save
	end

	def update_channel_image
		@channel = Channel.find(params[:id])
		@channel.image = params[:image]
		if @channel.save
			@success = true
		else
			render status: 500
		end
	end

	def search_channels
		channels = Channel.all.order(name: :asc)
		@filtered_channels = Array.new

		channels.each do |channel|
			if channel.matches?(params[:search])
				@filtered_channels.push(channel)
			end
		end
	end

	# Movie Methods
	#######################################################################################

	def view_movie
		@movie = Movie.find(params[:id])
	end

	def add_movie
		@movie = Movie.new
		@movie.name = params[:new_name]
		@movie.roku = params[:new_roku]
		@movie.ios = params[:new_ios]
		@movie.android = params[:new_android]
		@movie.web = params[:new_web]
		@movie.free = params[:new_free]
		@movie.stream_url = params[:new_stream_url]
		@movie.content_quality = params[:new_content_quality]
		@movie.bitrate = params[:new_bitrate]
		@movie.synopsis = params[:new_synopsis]
		@movie.genres = params[:new_genres]
		@movie.actors = params[:new_actors]
		@movie.save
	end

	def update_movie
		@movie = Movie.find(params[:id])
		@movie.name = params[:name]
		@movie.roku = params[:roku]
		@movie.ios = params[:ios]
		@movie.android = params[:android]
		@movie.web = params[:web]
		@movie.free = params[:free]
		@movie.stream_url = params[:stream_url]
		@movie.content_quality = params[:content_quality]
		@movie.bitrate = params[:bitrate]
		@movie.synopsis = params[:synopsis]
		@movie.genres = params[:genres]
		@movie.actors = params[:actors]
		@movie.save
	end

	def update_movie_image
		@movie = Movie.find(params[:id])
		@movie.image = params[:image]
		if @movie.save
			@success = true
		else
			render status: 500
		end
	end

	def search_movies
		movies = Movie.all.order(name: :asc)
		@filtered_movies = Array.new

		movies.each do |movie|
			if movie.matches?(params[:search])
				@filtered_movies.push(movie)
			end
		end
	end

	# TV Show Methods
	#######################################################################################

	def view_show
		@show = Show.find(params[:id])
		@episodes = Episode.where(show_id: @show.id).order(episode_number: :desc)
	end

	def add_show
		@show = Show.new
		@show.name = params[:new_name]
		@show.roku = params[:new_roku]
		@show.ios = params[:new_ios]
		@show.android = params[:new_android]
		@show.web = params[:new_web]
		@show.free = params[:new_free]
		@show.content_quality = params[:new_content_quality]
		@show.content_type = params[:new_content_type]
		@show.bitrate = params[:new_bitrate]
		@show.synopsis = params[:new_synopsis]
		@show.genres = params[:new_genres]
		@show.actors = params[:new_actors]
		@show.save
	end

	def update_show
		@show = Show.find(params[:id])
		@show.name = params[:name]
		@show.roku = params[:roku]
		@show.ios = params[:ios]
		@show.android = params[:android]
		@show.web = params[:web]
		@show.free = params[:free]
		@show.content_quality = params[:content_quality]
		@show.content_type = params[:content_type]
		@show.bitrate = params[:bitrate]
		@show.synopsis = params[:synopsis]
		@show.genres = params[:genres]
		@show.actors = params[:actors]
		@show.save
	end

	def update_show_image
		@show = Show.find(params[:id])
		@show.image = params[:image]
		if @show.save
			@success = true
		else
			render status: 500
		end
	end

	def search_shows
		shows = Show.all.order(name: :asc)
		@filtered_shows = Array.new

		shows.each do |show|
			if show.matches?(params[:search])
				@filtered_shows.push(show)
			end
		end
	end

	# Episode Methods
	#######################################################################################

	def add_episode
		@show = Show.find(params[:show_id])
		@episode = Episode.new
		@episode.show_id = @show.id
		@episode.title = params[:new_ep_title]
		@episode.episode_number = params[:new_ep_episode_number]
		@episode.stream_url = params[:new_ep_stream_url]
		@episode.release_date = params[:new_ep_release_date]
		@episode.synopsis = params[:new_ep_synopsis]
		@episode.length = params[:new_ep_length]
		if @episode.save
			@episodes = Episode.where(show_id: @show.id).order(episode_number: :desc)
		end
	end

	def view_episode
		@episode = Episode.find(params[:id])
	end

	def update_episode
		@show = Show.find(params[:edit_ep_show_id])
		@episode = Episode.find(params[:edit_ep_id])
		@episode.show_id = @show.id
		@episode.title = params[:edit_ep_title]
		@episode.episode_number = params[:edit_ep_episode_number]
		@episode.stream_url = params[:edit_ep_stream_url]
		@episode.release_date = params[:edit_ep_release_date]
		@episode.synopsis = params[:edit_ep_synopsis]
		@episode.length = params[:edit_ep_length]
		if @episode.save
			@episodes = Episode.where(show_id: @show.id).order(episode_number: :desc)
		end
	end

	def search_episodes
		episodes = Episode.where(show_id: params[:id]).order(episode_number: :desc)
		@filtered_episodes = Array.new

		episodes.each do |episode|
			if episode.matches?(params[:search])
				@filtered_episodes.push(episode)
			end
		end
	end


	# Category/Grid Methods
	#######################################################################################

	def add_grid
		@category = Category.new
		@category.name = params[:new_name]
		@category.content_type = params[:new_content_type]
		@category.content_quality = params[:new_content_quality]
		@category.item_type = params[:new_item_type]
		@category.rank = params[:new_rank]
		@category.free = params[:new_free]
		@category.genre = params[:new_genre]
		@category.save
	end
	def update_grid
		@category = Category.find(params[:id])
		@category.name = params[:name]
		@category.content_type = params[:content_type]
		@category.content_quality = params[:content_quality]
		@category.item_type = params[:item_type]
		@category.rank = params[:rank]
		@category.free = params[:free]
		@category.genre = params[:genre]
		@category.save
	end
	def view_grid
		@category = Category.find(params[:id])
	end
	def delete_grid
		Category.find(params[:id]).destroy
	end

	# Watch Methods
	#######################################################################################
	def watch_channel
		@channel = Channel.find(params[:channel_id])
	end

	def browse_episodes
		@show = Show.find(params[:show_id])
		@episodes = Episode.where(show_id: @show.id).order(episode_number: :desc)
	end
	def watch_episode
		@show = Show.find(params[:show_id])
		@episode = Episode.where(show_id: @show.id, episode_number: params[:episode_number]).first
		@episodes = Episode.where(show_id: @show.id).order(episode_number: :desc)
	end

	def watch_movie
		@movie = Movie.find(params[:movie_id])
	end

	def navbar_search
		@channels = Channel.search params[:search], limit: 3, operator: "or", where: {web: true}
		@shows = Show.search params[:search], limit: 3, operator: "or", where: {web: true}
		@movies = Movie.search params[:search], limit: 3, operator: "or", where: {web: true}
	end

	def channel
		@channel = Channel.find(params[:channel_id])
		if @channel.available?('web')
			@episodes = Episode.where(channel_id: @channel.id).order(episode_number: :desc)
		else
			flash[:notice] = 'That channel is not available on the web!'
			redirect_to root_url and return
		end
	end
	def watch_video
		@channel = Channel.find(params[:channel_id])
		if @channel.available?('web')
			@episodes = Episode.where(channel_id: @channel.id).order(episode_number: :desc)
			@episode = Episode.find(params[:episode_id])
		else
			flash[:notice] = 'That channel is not available on the web!'
			redirect_to root_url and return
		end
	end
end
