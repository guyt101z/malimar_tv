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
			if params[:new_stream_url].present? && params[:new_stream_url].start_with?('http://')
				params[:new_stream_url].gsub!('http://','')
			end
			if params[:new_stream_url].present? && params[:new_stream_url].start_with?('rtmp://')
				params[:new_stream_url].gsub!('rtmp://','')
			end
			if params[:new_stream_url].present? && params[:new_stream_url].end_with?('/playlist.m3u8')
				params[:new_stream_url].gsub!('/playlist.m3u8','')
			end
			@channel.stream_url = params[:new_stream_url]
			@channel.content_type = params[:new_content_type]
			@channel.disable_playlist = params[:new_disable_playlist]
			@channel.content_quality = params[:new_content_quality]
			@channel.bitrate = params[:new_bitrate]
			@channel.synopsis = params[:new_synopsis]
			@channel.genres = params[:new_genres]
			@channel.actors = params[:new_actors]
			@channel.stream_name = params[:new_stream_name]
			@channel.adult = params[:new_adult]
			@channel.rating = params[:new_rating]

			if params[:new_web_url].present? && params[:new_web_url].start_with?('http://')
				params[:new_web_url].gsub!('http://','')
			end
			if params[:new_web_url].present? && params[:new_web_url].start_with?('rtmp://')
				params[:new_web_url].gsub!('rtmp://','')
			end
			if params[:new_web_url].present? && params[:new_web_url].end_with?('/playlist.m3u8')
				params[:new_web_url].gsub!('/playlist.m3u8','')
			end
			@channel.web_url = params[:new_web_url]
			@channel.use_web_url = params[:new_use_web_url]
			@channel.added_by = current_admin.id
			if @channel.save
				if params[:new_grids].present?
					params[:new_grids].each do |g|
						if GridItem.where(video_type: 'Channel', grid_id: g.to_i, video_id: @channel.id).first.nil?
							grid_item = GridItem.new(video_type: 'Channel', grid_id: g.to_i, video_id: @channel.id)
							grid_item.save
						end
					end
				end


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
			if params[:stream_url].present? && params[:stream_url].start_with?('http://')
				params[:stream_url].gsub!('http://','')
			end
			if params[:stream_url].present? && params[:stream_url].start_with?('rtmp://')
				params[:stream_url].gsub!('rtmp://','')
			end
			if params[:stream_url].present? && params[:stream_url].end_with?('/playlist.m3u8')
				params[:stream_url].gsub!('/playlist.m3u8','')
			end
			@channel.stream_url = params[:stream_url]
			@channel.content_type = params[:content_type]
			@channel.disable_playlist = params[:disable_playlist]
			@channel.content_quality = params[:content_quality]
			@channel.bitrate = params[:bitrate]
			@channel.synopsis = params[:synopsis]
			@channel.genres = params[:genres]
			@channel.actors = params[:actors]
			@channel.stream_name = params[:stream_name]
			@channel.front_page = params[:front_page]
			@channel.adult = params[:adult]
			@channel.rating = params[:rating]

			if params[:web_url].present? && params[:web_url].start_with?('http://')
				params[:web_url].gsub!('http://','')
			end
			if params[:web_url].present? && params[:web_url].start_with?('rtmp://')
				params[:web_url].gsub!('rtmp://','')
			end
			if params[:web_url].present? && params[:web_url].end_with?('/playlist.m3u8')
				params[:web_url].gsub!('/playlist.m3u8','')
			end
			@channel.web_url = params[:web_url]
			@channel.use_web_url = params[:use_web_url]
			@channel.edited_by = current_admin.id
			if @channel.save
				if params[:grids].present?
					params[:grids].each do |g|
						if GridItem.where(video_type: 'Channel', grid_id: g.to_i, video_id: @channel.id).first.nil?
							grid_item = GridItem.new(video_type: 'Channel', grid_id: g.to_i, video_id: @channel.id)
							grid_item.save
						end
					end
				end
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
			if params[:new_stream_url].present? && params[:new_stream_url].start_with?('http://')
				params[:new_stream_url].gsub!('http://','')
			end
			if params[:new_stream_url].present? && params[:new_stream_url].start_with?('rtmp://')
				params[:new_stream_url].gsub!('rtmp://','')
			end
			if params[:new_stream_url].present? && params[:new_stream_url].end_with?('/playlist.m3u8')
				params[:new_stream_url].gsub!('/playlist.m3u8','')
			end
			@movie.stream_url = params[:new_stream_url]
			@movie.disable_playlist = params[:new_disable_playlist]
			@movie.content_quality = params[:new_content_quality]
			@movie.bitrate = params[:new_bitrate]
			@movie.synopsis = params[:new_synopsis]
			@movie.genres = params[:new_genres]
			@movie.actors = params[:new_actors]
			@movie.length = params[:new_length]
			@movie.release_date = params[:new_release_date]
			@movie.adult = params[:new_adult]
			@movie.grid_id = params[:new_grid_id]
			@movie.rating = params[:new_rating]

			if params[:new_web_url].present? && params[:new_web_url].start_with?('http://')
				params[:new_web_url].gsub!('http://','')
			end
			if params[:new_web_url].present? && params[:new_web_url].start_with?('rtmp://')
				params[:new_web_url].gsub!('rtmp://','')
			end
			if params[:new_web_url].present? && params[:new_web_url].end_with?('/playlist.m3u8')
				params[:new_web_url].gsub!('/playlist.m3u8','')
			end
			@movie.web_url = params[:new_web_url]
			@movie.use_web_url = params[:new_use_web_url]
			@movie.added_by = current_admin.id
			if @movie.save
				if params[:new_grids].present?
					params[:new_grids].each do |g|
						if GridItem.where(video_type: 'Movie', grid_id: g.to_i, video_id: @movie.id).first.nil?
							grid_item = GridItem.new(video_type: 'Movie', grid_id: g.to_i, video_id: @movie.id)
							grid_item.save
						end
					end
				end
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
			if params[:stream_url].present? && params[:stream_url].start_with?('http://')
				params[:stream_url].gsub!('http://','')
			end
			if params[:stream_url].present? && params[:stream_url].start_with?('rtmp://')
				params[:stream_url].gsub!('rtmp://','')
			end
			if params[:stream_url].present? && params[:stream_url].end_with?('/playlist.m3u8')
				params[:stream_url].gsub!('/playlist.m3u8','')
			end
			@movie.stream_url = params[:stream_url]
			@movie.disable_playlist = params[:disable_playlist]
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
			@movie.rating = params[:rating]

			if params[:web_url].present? && params[:web_url].start_with?('http://')
				params[:web_url].gsub!('http://','')
			end
			if params[:web_url].present? && params[:web_url].start_with?('rtmp://')
				params[:web_url].gsub!('rtmp://','')
			end
			if params[:web_url].present? && params[:web_url].end_with?('/playlist.m3u8')
				params[:web_url].gsub!('/playlist.m3u8','')
			end
			@movie.web_url = params[:web_url]
			@movie.use_web_url = params[:use_web_url]
			@movie.edited_by = current_admin.id
			if @movie.save
				if params[:grids].present?
					params[:grids].each do |g|
						if GridItem.where(video_type: 'Movie', grid_id: g.to_i, video_id: @movie.id).first.nil?
							grid_item = GridItem.new(video_type: 'Movie', grid_id: g.to_i, video_id: @movie.id)
							grid_item.save
						end
					end
				end
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
			@show.disable_playlist = params[:new_disable_playlist]
			@show.add_date = params[:new_add_date]
			@show.add_ep_num = params[:new_add_ep_num]
			if params[:new_url].present? && params[:new_url].start_with?('http://')
				params[:new_url].gsub!('http://','')
			end
			if params[:new_url].present? && params[:new_url].start_with?('rtmp://')
				params[:new_url].gsub!('rtmp://','')
			end
			if params[:new_url].present? && params[:new_url].end_with?('/playlist.m3u8')
				params[:new_url].gsub!('/playlist.m3u8','')
			end
			@show.url = params[:new_url]

			if params[:new_web_url].present? && params[:new_web_url].start_with?('http://')
				params[:new_web_url].gsub!('http://','')
			end
			if params[:new_web_url].present? && params[:new_web_url].start_with?('rtmp://')
				params[:new_web_url].gsub!('rtmp://','')
			end
			if params[:new_web_url].present? && params[:new_web_url].end_with?('/playlist.m3u8')
				params[:new_web_url].gsub!('/playlist.m3u8','')
			end
			@show.web_url = params[:new_web_url]
			@show.use_web_url = params[:new_use_web_url]
			@show.added_by = current_admin.id
			if @show.save
				if params[:new_grids].present?
					params[:new_grids].each do |g|
						if GridItem.where(video_type: 'Show', grid_id: g.to_i, video_id: @show.id).first.nil?
							grid_item = GridItem.new(video_type: 'Show', grid_id: g.to_i, video_id: @show.id)
							grid_item.save
						end
					end
				end
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
			@show.rating = params[:rating]
			@show.disable_playlist = params[:disable_playlist]
			@show.add_date = params[:add_date]
			@show.add_ep_num = params[:add_ep_num]
			if params[:url].present? && params[:url].start_with?('http://')
				params[:url].gsub!('http://','')
			end
			if params[:url].present? && params[:url].start_with?('rtmp://')
				params[:url].gsub!('rtmp://','')
			end
			if params[:url].present? && params[:url].end_with?('/playlist.m3u8')
				params[:url].gsub!('/playlist.m3u8','')
			end
			@show.url = params[:url]

			if params[:web_url].present? && params[:web_url].start_with?('http://')
				params[:web_url].gsub!('http://','')
			end
			if params[:web_url].present? && params[:web_url].start_with?('rtmp://')
				params[:web_url].gsub!('rtmp://','')
			end
			if params[:web_url].present? && params[:web_url].end_with?('/playlist.m3u8')
				params[:web_url].gsub!('/playlist.m3u8','')
			end
			@show.web_url = params[:web_url]
			@show.use_web_url = params[:use_web_url]
			@show.edited_by = current_admin.id
			if @show.save
				if params[:grids].present?
					params[:grids].each do |g|
						if GridItem.where(video_type: 'Show', grid_id: g.to_i, video_id: @show.id).first.nil?
							grid_item = GridItem.new(video_type: 'Show', grid_id: g.to_i, video_id: @show.id)
							grid_item.save
						end
					end
				end
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
			@episode.release_date = params[:new_ep_release_date]
			@episode.synopsis = params[:new_ep_synopsis]
			@episode.length = params[:new_ep_length]
			@episode.final = params[:new_ep_final]
			@episode.added_by = current_admin.id
			if @episode.save
				@episodes = Episode.where(show_id: @show.id).order(episode_number: :desc)

				if @episode.final?
					@episodes.each do |e|
						unless e.id == @episode.id
							e.final = false
							e.save
						end
					end
				end

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
			@episode.release_date = params[:edit_ep_release_date]
			@episode.synopsis = params[:edit_ep_synopsis]
			@episode.length = params[:edit_ep_length]
			@episode.final = params[:edit_ep_final]
			@episode.edited_by = current_admin.id
			if @episode.save
				@episodes = Episode.where(show_id: @show.id).order(episode_number: :desc)

				if @episode.final?
					@episodes.each do |e|
						unless e.id == @episode.id
							e.final = false
							e.save
						end
					end
				end

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
		@category = Grid.new
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

	def update_grid_items
		@grid = Grid.find(params[:id])

		@grid.grid_items.each do |i|
			i.weight = params["#{i.id.to_s}"]
			i.save
		end
	end

	def view_grid
		@category = Grid.find(params[:id])
	end

	# Watch Methods
	#######################################################################################
	def watch_channel
		@channel = Channel.where(slug: params[:channel_slug]).first

		activation_status = Setting.where(name: 'Active Registration').first.data

		if @channel.free == false && (activation_status == 'false' || activation_status == false)
			redirect_to root_url(show_premium_modal: true)
		end

		if @channel.adult?
			unless (user_signed_in? && current_user.adult?) || admin_signed_in? 
				flash[:error] = 'You are not permitted to watch adult content'
				redirect_to '/'
			end
		end

		@token = generate_token(@channel.stream_name)
	end

	def browse_episodes
		@show = Show.where(slug: params[:show_slug]).first

		activation_status = Setting.where(name: 'Active Registration').first.data

		if @show.free == false && (activation_status == 'false' || activation_status == false)
			redirect_to root_url(show_premium_modal: true)
		end

		if @show.adult?
			unless (user_signed_in? && current_user.adult?) || admin_signed_in? 
				flash[:error] = 'You are not permitted to watch adult content'
				redirect_to '/'
			end
		end

		@episodes = Episode.where(show_id: @show.id).order(episode_number: :desc)
		unless params[:method].present? && params[:method] == 'all'
			@episodes = @episodes.paginate(page: params[:page], per_page: 10)
		end
	end
	def watch_episode
		@show = Show.where(slug: params[:show_slug]).first

		activation_status = Setting.where(name: 'Active Registration').first.data

		if @show.free == false && (activation_status == 'false' || activation_status == false)
			redirect_to root_url(show_premium_modal: true)
		end

		if @show.adult?
			unless (user_signed_in? && current_user.adult?) || admin_signed_in? 
				flash[:error] = 'You are not permitted to watch adult content'
				redirect_to '/'
			end
		end

		@episode = Episode.where(show_id: @show.id, episode_number: params[:episode_number]).first
		if user_signed_in?
			show_update = ShowProgress.where(user_id: current_user.id, show_id: @show.id).first
			if show_update.nil?
				@episode_update = nil
			else
				@episode_update = EpisodeProgress.where(show_progress_id: show_update.id, episode_id: @episode.id).first
			end
		end

		episodes_ordered = Episode.where(show_id: @show.id).order(episode_number: :asc)

		@episodes_reordered = Array.new
		start_index = @episode.episode_number - 1

		episodes_ordered.each_with_index do |episode, index|
			if index > start_index
				@episodes_reordered.push(episode)
			end
		end

		episodes_ordered.each_with_index do |episode, index|
			if index <= start_index
				@episodes_reordered.push(episode)
			end
		end
	end

	def watch_movie
		@movie = Movie.where(slug: params[:movie_slug]).first

		activation_status = Setting.where(name: 'Active Registration').first.data

		if @movie.free == false && (activation_status == 'false' || activation_status == false)
			redirect_to root_url(show_premium_modal: true)
		end

		if @movie.adult?
			unless (user_signed_in? && current_user.adult?) || admin_signed_in? 
				flash[:error] = 'You are not permitted to watch adult content'
				redirect_to '/'
			end
		end

		if user_signed_in?
			@movie_update = MovieProgress.where(user_id: current_user.id, movie_id: @movie.id).first
		end
	end

	def navbar_search
		search_params = {web: true}
		if user_signed_in? && current_user.adult == true
			search_params[:adult] = true
		end
		@channels = Channel.search params[:search], where: search_params, fields: ['title^100','synopsis'], operator: 'or'
		@shows = Show.search params[:search], where: search_params, fields: ['title^100','synopsis'], operator: 'or'
		@movies = Movie.search params[:search], where: search_params, fields: ['title^100','synopsis'], operator: 'or'
	end

	def landing
		@grids = Grid.where(home_page: true).order(weight: :asc)

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
		@grid = Grid.find(params[:category_id])

		activation_status = Setting.where(name: 'Active Registration').first.data

		if @grid.free == false && (activation_status == 'false' || activation_status == false)
			redirect_to root_url(show_premium_modal: true)
		end

		if @grid.adult?
			unless (user_signed_in? && current_user.adult?) || admin_signed_in? 
				flash[:error] = 'You are not permitted to watch adult content'
				redirect_to '/'
			end
		end
	end

	def remote_sign_in_for_video
		status = Setting.where(name: 'Active Registration').first.data
		unless status == 'true'
			@error = 'Sign in is currently not active'
		else
			user = User.authenticate(params[:email],params[:password])

			if user.nil?
				@error = 'Invalid email or password'
			else
				sign_in(user, bypass: true)
				flash[:success] = "Welcome back, #{user.name}"
				@error = nil
			end
		end
	end

	def submit_broken_link
		if params[:video_type] == 'Show'
			already_submitted = BrokenLink.already_submitted?(current_user.id, params[:video_id], params[:video_type], params[:episode_number])
		else
			already_submitted = BrokenLink.already_submitted?(current_user.id, params[:video_id], params[:video_type], nil)
		end
		unless already_submitted
			if params[:video_type] == 'Show'
				link = BrokenLink.new(user_id: current_user.id, video_id: params[:video_id], video_type: params[:video_type], episode_number: params[:episode_number])
			else
				link = BrokenLink.new(user_id: current_user.id, video_id: params[:video_id], video_type: params[:video_type])
			end
			if link.save
				@success = true
			else
				@success = false
			end
		else
			@success = false
		end
	end

	def grid_view
		@grid = Grid.find(params[:id])
	end

	def gen_half
		generate_random_half(20)
	end

	private

	def generate_token(stream_name)
		require 'digest/md5'
		private_token = Setting.where(name: 'WMS Token').first.data

		random_half = generate_random_half(Random.new.rand(20))
		token_creation_time = (Time.now.to_i + 60)*1000
		token_string = "#{stream_name}-#{token_creation_time}-#{random_half}-#{private_token}"
		encode = Digest::MD5.hexdigest(token_string)
		token_hash_string = "#{stream_name}-#{token_creation_time}-#{random_half}-#{encode}"

		return token_hash_string
	end

	def generate_random_half(chars)
		random_gen = Random.new
		random = ''

		for i in 0..chars
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
