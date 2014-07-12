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

	def view_channel
		@channel = Channel.find(params[:id])
		@episodes = Episode.where(channel_id: @channel.id).order(episode_number: :asc)
	end

	def add_channel
		@channel = Channel.new
		@channel.name = params[:new_name]
		@channel.roku = params[:new_roku]
		@channel.ios = params[:new_ios]
		@channel.android = params[:new_android]
		@channel.web = params[:new_web]
		@channel.free = params[:new_free]
		@channel.live = params[:new_live]
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
		@channel.live = params[:live]
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

	def add_episode
		@channel = Channel.find(params[:channel_id])
		@episode = Episode.new
		@episode.channel_id = @channel.id
		@episode.title = params[:new_ep_title]
		@episode.episode_number = params[:new_ep_episode_number]
		@episode.stream_url = params[:new_ep_stream_url]
		@episode.release_date = params[:new_ep_release_date]
		@episode.content_type = params[:new_ep_content_type]
		@episode.content_quality = params[:new_ep_content_quality]
		@episode.bitrate = params[:new_ep_bitrate]
		@episode.actors = params[:new_ep_actors]
		@episode.genres = params[:new_ep_genres]
		@episode.synopsis = params[:new_ep_synopsis]
		@episode.length = params[:new_ep_length]
		if @episode.save
			@episodes = Episode.where(channel_id: @channel.id).order(episode_number: :asc)
		end
	end

	def view_episode
		@episode = Episode.find(params[:id])
	end

	def update_episode
		@channel = Channel.find(params[:edit_ep_channel_id])
		@episode = Episode.find(params[:edit_ep_id])
		@episode.channel_id = @channel.id
		@episode.title = params[:edit_ep_title]
		@episode.episode_number = params[:edit_ep_episode_number]
		@episode.stream_url = params[:edit_ep_stream_url]
		@episode.release_date = params[:edit_ep_release_date]
		@episode.content_type = params[:edit_ep_content_type]
		@episode.content_quality = params[:edit_ep_content_quality]
		@episode.bitrate = params[:edit_ep_bitrate]
		@episode.actors = params[:edit_ep_actors]
		@episode.genres = params[:edit_ep_genres]
		@episode.synopsis = params[:edit_ep_synopsis]
		@episode.length = params[:edit_ep_length]
		if @episode.save
			@episodes = Episode.where(channel_id: @channel.id).order(episode_number: :asc)
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

	def search_episodes
		episodes = Episode.where(channel_id: params[:id]).order(episode_number: :asc)
		@filtered_episodes = Array.new

		episodes.each do |episode|
			if episode.matches?(params[:search])
				@filtered_episodes.push(episode)
			end
		end
	end

	def navbar_search
		@channels = Channel.search params[:search], limit: 3, operator: "or", where: {web: true}
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
