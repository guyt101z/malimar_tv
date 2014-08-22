class VideosController < ApplicationController

	# Channel Methods
	#######################################################################################

	def view_channel
		if current_admin.authorized_to?('update_videos')
			@channel = Channel.find(params[:id])
		else
			flash[:error] = 'You are not authorized to view that.'
			redirect_to '/admins'
		end
	end

	def add_channel
		if current_admin.authorized_to?('update_videos')
			@channel = Channel.new
			@channel.name = params[:new_name]
			@channel.roku = params[:new_roku]
			@channel.ios = params[:new_ios]
			@channel.android = params[:new_android]
			@channel.web = params[:new_web]
			@channel.free = params[:new_free]
			@channel.stream_url = params[:new_stream_url]
			@channel.rtmp_url = params[:new_rtmp_url]
			@channel.content_type = params[:new_content_type]
			@channel.content_quality = params[:new_content_quality]
			@channel.bitrate = params[:new_bitrate]
			@channel.synopsis = params[:new_synopsis]
			@channel.genres = params[:new_genres]
			@channel.actors = params[:new_actors]
			@channel.stream_name = params[:new_stream_name]
			@channel.adult = params[:new_adult]
			@channel.grid_id = params[:new_grid_id]
			if @channel.save
				Channel.reindex
				AdminActivity.create(admin_id: current_admin.id,
									data: YAML.dump({
										type: 'New Channel',
										message: "#{current_admin.name} created a new live channel.",
										channel_id: @channel.id
									}))
			end
		else
			render status: 403
		end
	end

	def update_channel
		if current_admin.authorized_to?('update_videos')
			@channel = Channel.find(params[:id])
			@channel.name = params[:name]
			@channel.roku = params[:roku]
			@channel.ios = params[:ios]
			@channel.android = params[:android]
			@channel.web = params[:web]
			@channel.free = params[:free]
			@channel.stream_url = params[:stream_url]
			@channel.rtmp_url = params[:rtmp_url]
			@channel.content_type = params[:content_type]
			@channel.content_quality = params[:content_quality]
			@channel.bitrate = params[:bitrate]
			@channel.synopsis = params[:synopsis]
			@channel.genres = params[:genres]
			@channel.actors = params[:actors]
			@channel.stream_name = params[:stream_name]
			@channel.front_page = params[:front_page]
			@channel.adult = params[:adult]
			@channel.grid_id = params[:grid_id]
			if @channel.save
				Channel.reindex
				AdminActivity.create(admin_id: current_admin.id,
									data: YAML.dump({
										type: 'Updated Channel',
										message: "#{current_admin.name} updated a live channel.",
										channel_id: @channel.id
									}))
			end
		else
			render status: 403
		end
	end

	def update_channel_image
		if current_admin.authorized_to?('update_videos')
			@channel = Channel.find(params[:id])
			@channel.image = params[:image]
			if @channel.save
				@success = true
			else
				render status: 500
			end
		else
			render status: 403
		end
	end

	def update_channel_banner
		if current_admin.authorized_to?('update_videos')
			@channel = Channel.find(params[:id])
			@channel.banner = params[:banner]
			if @channel.save
				@success = true
			else
				render status: 500
			end
		else
			render status: 403
		end
	end

	def search_channels
		if current_admin.authorized_to?('update_videos')
			channels = Channel.all.order(name: :asc)
			@filtered_channels = Array.new

			channels.each do |channel|
				if channel.matches?(params[:search])
					@filtered_channels.push(channel)
				end
			end
		else
			render status: 403
		end
	end

	def delete_channel
		if current_admin.authorized_to?('update_videos')
			channel = Channel.find(params[:id])
			@id = channel.id
			channel.destroy
			Channel.reindex
		else
			render status: 403
		end
	end

	# Movie Methods
	#######################################################################################

	def view_movie
		if current_admin.authorized_to?('update_videos')
			@movie = Movie.find(params[:id])
		else
			flash[:error] = 'You are not authorized to view that.'
			redirect_to '/admins'
		end
	end

	def add_movie
		if current_admin.authorized_to?('update_videos')
			@movie = Movie.new
			@movie.name = params[:new_name]
			@movie.roku = params[:new_roku]
			@movie.ios = params[:new_ios]
			@movie.android = params[:new_android]
			@movie.web = params[:new_web]
			@movie.free = params[:new_free]
			@movie.stream_url = params[:new_stream_url]
			@movie.rtmp_url = params[:new_rtmp_url]
			@movie.content_quality = params[:new_content_quality]
			@movie.bitrate = params[:new_bitrate]
			@movie.synopsis = params[:new_synopsis]
			@movie.genres = params[:new_genres]
			@movie.actors = params[:new_actors]
			@movie.length = params[:new_length]
			@movie.release_date = params[:new_release_date]
			@movie.adult = params[:new_adult]
			@movie.grid_id = params[:new_grid_id]
			if @movie.save
				Movie.reindex
				AdminActivity.create(admin_id: current_admin.id,
									data: YAML.dump({
										type: 'New Movie',
										message: "#{current_admin.name} created a new movie.",
										movie_id: @movie.id
									}))
			end
		else
			render status: 403
		end
	end

	def update_movie
		if current_admin.authorized_to?('update_videos')
			@movie = Movie.find(params[:id])
			@movie.name = params[:name]
			@movie.roku = params[:roku]
			@movie.ios = params[:ios]
			@movie.android = params[:android]
			@movie.web = params[:web]
			@movie.free = params[:free]
			@movie.stream_url = params[:stream_url]
			@movie.rtmp_url = params[:rtmp_url]
			@movie.content_quality = params[:content_quality]
			@movie.bitrate = params[:bitrate]
			@movie.synopsis = params[:synopsis]
			@movie.genres = params[:genres]
			@movie.actors = params[:actors]
			@movie.length = params[:length]
			@movie.release_date = params[:release_date]
			@movie.front_page = params[:front_page]
			@movie.adult = params[:adult]
			@movie.grid_id = params[:grid_id]
			if @movie.save
				Movie.reindex
				AdminActivity.create(admin_id: current_admin.id,
									data: YAML.dump({
										type: 'Updated Movie',
										message: "#{current_admin.name} updated a movie.",
										movie_id: @movie.id
									}))
			end
		else
			render status: 403
		end
	end

	def update_movie_image
		if current_admin.authorized_to?('update_videos')
			@movie = Movie.find(params[:id])
			@movie.image = params[:image]
			if @movie.save
				@success = true
			else
				render status: 500
			end
		else
			render status: 403
		end
	end

	def update_movie_banner
		if current_admin.authorized_to?('update_videos')
			@movie = Movie.find(params[:id])
			@movie.banner = params[:banner]
			if @movie.save
				@success = true
			else
				render status: 500
			end
		else
			render status: 403
		end
	end

	def delete_movie
		if current_admin.authorized_to?('update_videos')
			movie = Movie.find(params[:id])
			@id = movie.id
			movie.destroy
			Movie.reindex
		else
			render status: 403
		end
	end

	def search_movies
		if current_admin.authorized_to?('update_videos')
			movies = Movie.all.order(name: :asc)
			@filtered_movies = Array.new

			movies.each do |movie|
				if movie.matches?(params[:search])
					@filtered_movies.push(movie)
				end
			end
		else
			render status: 403
		end
	end

	# TV Show Methods
	#######################################################################################

	def view_show
		if current_admin.authorized_to?('update_videos')
			@show = Show.find(params[:id])
			@episodes = Episode.where(show_id: @show.id).order(episode_number: :desc)
		else
			flash[:error] = 'You are not authorized to view that.'
			redirect_to '/admins'
		end
	end

	def add_show
		if current_admin.authorized_to?('update_videos')
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
			@show.adult = params[:new_adult]
			@show.grid_id = params[:new_grid_id]
			if @show.save
				Show.reindex
				AdminActivity.create(admin_id: current_admin.id,
									data: YAML.dump({
										type: 'New Show',
										message: "#{current_admin.name} created a new on demand show.",
										show_id: @show.id
									}))
			end
		else
			render status: 403
		end
	end

	def update_show
		if current_admin.authorized_to?('update_videos')
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
			@show.front_page = params[:front_page]
			@show.adult = params[:adult]
			@show.grid_id = params[:grid_id]
			if @show.save
				Show.reindex
				AdminActivity.create(admin_id: current_admin.id,
									data: YAML.dump({
										type: 'Updated Show',
										message: "#{current_admin.name} updated a on demand show.",
										show_id: @show.id
									}))
			end
		else
			render status: 403
		end
	end

	def update_show_image
		if current_admin.authorized_to?('update_videos')
			@show = Show.find(params[:id])
			@show.image = params[:image]
			if @show.save
				@success = true
			else
				render status: 500
			end
		else
			render status: 403
		end
	end

	def update_show_banner
		if current_admin.authorized_to?('update_videos')
			@show = Show.find(params[:id])
			@show.banner = params[:banner]
			if @show.save
				@success = true
			else
				render status: 500
			end
		else
			render status: 403
		end
	end

	def delete_show
		if current_admin.authorized_to?('update_videos')
			show = Show.find(params[:id])
			episodes = Episode.where(show_id: show.id)
			@id = show.id

			show.destroy
			episodes.each do |episode|
				episode.destroy
			end
			Show.reindex
		else
			render status: 403
		end
	end

	def search_shows
		if current_admin.authorized_to?('update_videos')
			shows = Show.all.order(name: :asc)
			@filtered_shows = Array.new

			shows.each do |show|
				if show.matches?(params[:search])
					@filtered_shows.push(show)
				end
			end
		else
			render status: 403
		end
	end

	# Episode Methods
	#######################################################################################

	def add_episode
		if current_admin.authorized_to?('update_videos')
			@show = Show.find(params[:show_id])
			@episode = Episode.new
			@episode.show_id = @show.id
			@episode.title = params[:new_ep_title]
			@episode.episode_number = params[:new_ep_episode_number]
			@episode.stream_url = params[:new_ep_stream_url]
			@episode.rtmp_url = params[:new_ep_rtmp_url]
			@episode.release_date = params[:new_ep_release_date]
			@episode.synopsis = params[:new_ep_synopsis]
			@episode.length = params[:new_ep_length]
			if @episode.save
				@episodes = Episode.where(show_id: @show.id).order(episode_number: :desc)
				AdminActivity.create(admin_id: current_admin.id,
									data: YAML.dump({
										type: 'New Episode',
										message: "#{current_admin.name} created a new episode for #{@show.name}.",
										show_id: @show.id,
										episode_id: @episode.id
									}))
			end
		else
			render status: 403
		end
	end

	def view_episode
		if current_admin.authorized_to?('update_videos')
			@episode = Episode.find(params[:id])
		else
			render status: 403
		end
	end

	def update_episode
		if current_admin.authorized_to?('update_videos')
			@show = Show.find(params[:edit_ep_show_id])
			@episode = Episode.find(params[:edit_ep_id])
			@episode.show_id = @show.id
			@episode.title = params[:edit_ep_title]
			@episode.episode_number = params[:edit_ep_episode_number]
			@episode.stream_url = params[:edit_ep_stream_url]
			@episode.rtmp_url = params[:edit_ep_rtmp_url]
			@episode.release_date = params[:edit_ep_release_date]
			@episode.synopsis = params[:edit_ep_synopsis]
			@episode.length = params[:edit_ep_length]
			if @episode.save
				@episodes = Episode.where(show_id: @show.id).order(episode_number: :desc)

				AdminActivity.create(admin_id: current_admin.id,
									data: YAML.dump({
										type: 'Updated Episode',
										message: "#{current_admin.name} updated an episode for #{@show.name}.",
										show_id: @show.id,
										episode_id: @episode.id
									}))
			end
		else
			render status: 403
		end
	end

	def delete_episode
		if current_admin.authorized_to?('update_videos')
			episode = Episode.find(params[:id])
			@id = episode.id
			@show = Show.find(episode.show_id)
			episode.destroy
		else
			render status: 403
		end
	end

	def search_episodes
		if current_admin.authorized_to?('update_videos')
			episodes = Episode.where(show_id: params[:id]).order(episode_number: :desc)
			@filtered_episodes = Array.new

			episodes.each do |episode|
				if episode.matches?(params[:search])
					@filtered_episodes.push(episode)
				end
			end
		else
			render status: 403
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
		@category.front_page = params[:new_front_page]
		@category.sort = params[:new_sort]
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
		@category.front_page = params[:front_page]
		@category.sort = params[:sort]
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
		if user_signed_in? || admin_signed_in?
			@channel = Channel.find(params[:channel_id])
			@token = generate_token(@channel.stream_name)

			unless @channel.free? || admin_signed_in?
				premium_wall
			end
		else
			flash[:notice] = 'You mus sign up or sign in to watch videos'
			redirect_to '/'
		end
	end

	def browse_episodes
		if user_signed_in? || admin_signed_in?
			@show = Show.find(params[:show_id])
			@episodes = Episode.where(show_id: @show.id).order(episode_number: :desc)
			@episodes = @episodes.paginate(page: params[:page], per_page: 10)

			unless @show.free? || admin_signed_in?
				premium_wall
			end
		else
			flash[:notice] = 'You mus sign up or sign in to watch videos'
			redirect_to '/'
		end
	end
	def watch_episode
		if user_signed_in? || admin_signed_in?
			@show = Show.find(params[:show_id])
			@episode = Episode.where(show_id: @show.id, episode_number: params[:episode_number]).first

			@episodes = Episode.where(show_id: @show.id).order(episode_number: :desc)

			unless @show.free? || admin_signed_in?
				premium_wall
			end
		else
			flash[:notice] = 'You mus sign up or sign in to watch videos'
			redirect_to '/'
		end
	end

	def watch_movie
		if user_signed_in? || admin_signed_in?
			@movie = Movie.find(params[:movie_id])
			@token = generate_token(@movie.stream_name)

			unless @movie.free? || admin_signed_in?
				premium_wall
			end
		else
			flash[:notice] = 'You mus sign up or sign in to watch videos'
			redirect_to '/'
		end
	end

	def navbar_search
		search_params = {web: true}
		if user_signed_in? && current_user.adult == true
			search_params[:adult] = true
		end
		@channels = Channel.search params[:search], where: search_params, operator: 'or', limit: 3
		@shows = Show.search params[:search], where: search_params, operator: 'or', limit: 3
		@movies = Movie.search params[:search], where: search_params, operator: 'or', limit: 3
	end

	def landing
		@grids = Grid.where(home_page: true).order(weight: :desc)

		@front_page_array = Array.new

		Movie.where(front_page: true).each do |movie|
			unless movie.banner.nil?
				@front_page_array.push(movie)
			end
		end
		Channel.where(front_page: true).each do |channel|
			unless channel.banner.nil?
				@front_page_array.push(channel)
			end
		end
		Show.where(front_page: true).each do |show|
			unless show.banner.nil?
				@front_page_array.push(show)
			end
		end


	end

	def full_grid
		if user_signed_in? || admin_signed_in?
			@grid = Grid.find(params[:category_id])
		else
			flash[:notice] = 'You mus sign up or sign in to watch videos'
			redirect_to '/'
		end
	end

	private

	def generate_token(stream_name)
		require 'digest/md5'
		private_token = Setting.where(name: 'WMS Token').first.data

		random_half = generate_random_half(Random.new.rand(10..30))
		token_creation_time = (Time.now.to_i + 60)*1000
		token_string = "#{stream_name}-#{token_creation_time}-#{random_half}-#{private_token}"
		encode = Digest::MD5.hexdigest(token_string)
		token_hash_string = "#{stream_name}-#{token_creation_time}-#{random_half}-#{encode}"

		return token_hash_string
	end

	def generate_random_half(chars)
		random_gen = Random.new
		random = ''

		for i in 0...chars
			random_1 = random_gen.rand(0..1)
			random_2 = random_gen.rand(0..2)
			if random_1 == 0
				random += (random_gen.rand('a'.ord..'k'.ord)).chr
			elsif random_1 == 1
				random += random_gen.rand(0..9).to_s
			end

			if random_2 == 0
				random = random.downcase
			end
		end
		return random
	end

	def premium_wall
		if current_user.expiry.nil? || current_user.expiry < Date.today
			flash[:error] = 'You must be a premium member to access.'
			redirect_to root_url and return
		end
	end
end
