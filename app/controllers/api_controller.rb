class ApiController < ApplicationController
    def authenticate
        unless request.headers['email'].nil? || request.headers['password'].nil?
            user = User.authenticate(request.headers['email'], request.headers['password'])
        else
            user = nil
        end

        if user.nil?
            render json: {code: 207, success: false, message: 'Invalid username or password'}
        else
            if request.headers['device'].present?
                device = Device.where(id: request.headers['device'], user_id: user.id).first

                if device.nil?
                    code = 102
                    message = 'New device with token'
                    device = Device.new(user_id: user.id, serial: SecureRandom.hex(10), type: request.headers['devicetype'].capitalize, expiry: 90.days.from_now)
                    until device.save
                        device.serial = SecureRandom.hex(10)
                    end
                elsif device.expiry < Date.today
                    code = 101
                    message = 'Renewed token'
                    device.expiry = 90.days.from_now
                    until device.save
                        device.serial = SecureRandom.hex(10)
                    end
                else
                    code = 103
                    message = 'No renewal needed.'
                end
                render json: {code: code, success: true, message: message, token: device.serial, device_id: device.id}
            else
                if user.max_devices?
                    code = 207
                    message = 'User has met device limit'
                    success = false
                    render json: {code: code, success: success, message: message}
                elsif request.headers['devicetype'].blank? || (['ipad','ipod','iphone','android','roku'].include?(request.headers['devicetype']) == false)
                    code = 208
                    message = 'Invalid device type'
                    success = false
                    render json: {code: code, success: success, message: message}
                else
                    code = 102
                    message = 'New device with token'
                    begin
                        device = Device.new(user_id: user.id, serial: SecureRandom.hex(10), type: request.headers['devicetype'].capitalize, expiry: 90.days.from_now)
                        until device.save
                            device.serial = SecureRandom.hex(10)
                        end
                        render json: {code: code, success: success, message: message, token: device.serial, device_id: device.id}
                    rescue
                        render json: {code: 209, success: false, message: 'Unknown error – Device failed to save'}
                    end
                end
            end
        end
    end

    def home_grid
        auth = authenticate_for_grid(request.headers['token'], request.headers['device'])
        categories = Category.where(front_page: true).order(rank: :asc)


        data = {
            item_count: categories.count,
            items: Array.new
        }

        categories.each do |grid|
            filter_params = generate_grid_search_params(grid, params[:device])

            if grid.item_type == 'shows'
                all_items = Show.where(filter_params).order(name: :asc)
                filtered_items = Array.new

                unless grid.genre.blank?
                    all_items.each do |item|
                        filtered_items.push(item) if item.matches_genre?(grid.genre)
                    end
                else
                    filtered_items = all_items
                end
            elsif grid.item_type == 'movies'
                all_items = Movie.where(filter_params.except(:content_type)).order(name: :asc)
                filtered_items = Array.new

                unless grid.genre.blank?
                    all_items.each do |item|
                        filtered_items.push(item) if item.matches_genre?(grid.genre)
                    end
                else
                    filtered_items = all_items
                end
            else
                all_items = Channel.where(filter_params).order(name: :asc)
                filtered_items = Array.new

                unless grid.genre.blank?
                    all_items.each do |item|
                        filtered_items.push(item) if item.matches_genre?(grid.genre)
                    end
                else
                    filtered_items = all_items
                end
            end
            data[:items].push({title_count: filtered_items.count, title: grid.name,
                               feed: {url: json_view_grid_url(id: grid.id, token: params[:token], device: params[:device])}})

        end

        if auth == 100
            render json: {code: 100, success: true, message: 'Success', feed: data}
        else
            render json: {code: 204, success: false, message: 'Device not registered'}
        end
    end

    def view_grid
        auth = authenticate_for_grid(request.headers['token'], request.headers['device_id'])

        if auth == 100
            grid = Category.where(id: params[:id]).first

            if grid.nil?
                render json: {code: 204, success: false, message: 'Grid not found'}
            else
                filter_params = generate_grid_search_params(grid, params[:device])

                if grid.item_type == 'shows'
                    all_items = Show.where(filter_params).order(name: :asc)
                    filtered_items = Array.new

                    unless grid.genre.blank?
                        all_items.each do |item|
                            filtered_items.push(item) if item.matches_genre?(grid.genre)
                        end
                    else
                        filtered_items = all_items
                    end
                elsif grid.item_type == 'movies'
                    all_items = Movie.where(filter_params.except(:content_type)).order(name: :asc)
                    filtered_items = Array.new

                    unless grid.genre.blank?
                        all_items.each do |item|
                            filtered_items.push(item) if item.matches_genre?(grid.genre)
                        end
                    else
                        filtered_items = all_items
                    end
                else
                    all_items = Channel.where(filter_params).order(name: :asc)
                    filtered_items = Array.new

                    unless grid.genre.blank?
                        all_items.each do |item|
                            filtered_items.push(item) if item.matches_genre?(grid.genre)
                        end
                    else
                        filtered_items = all_items
                    end
                end

                data = {
                    item_count: filtered_items.count,
                    items: Array.new
                }

                filtered_items.each do |item|
                    data[:items].push({sd_img: root_url[0...-1]+item.image_url(:sd), hd_img: root_url[0...-1]+item.image_url(:hd),
                                       title: item.name, feed: root_url[0...-1]+item.device_url})
                end

                render json: {code: 100, success: true, message: 'Success', feed: data}
            end
        else
            render json: {code: auth, success: false, message: 'Grid not found'}
        end
    end

    def view_channel
        channel = Channel.where(id: params[:id]).first

        if channel.nil?
            render json: {code: 204, success: false, message: 'Title not found.'}
        else
            auth = channel.authenticate_for_json(request.headers['token'], request.headers['device'])

            if auth[:code] == 100
                data = Hash.new

                data[:id] = "#{channel.name.gsub(' ','_').gsub(/[^a-z0-9]/i,'')}#{channel.created_at.strftime('%-d-%B-%Y')}"
                data[:title] = channel.name
                data[:length] = 0
                data[:content_type] = channel.content_type
                data[:content_quality] = channel.content_quality
                data[:stream_format] = 'hls'
                data[:stream_url] = "#{channel.stream_url}?token=#{generate_token(channel.stream_name)}"
                data[:bitrate] = channel.bitrate

                data[:actors] = channel.actors.split(/\r\n/)
                data[:genres] = channel.genres.split(/\r\n/)
                data[:synopsis] = channel.synopsis

                render json: {code: 100, success: true, message: 'Success', feed: data}
            else
                render json: auth
            end
        end
    end

    def view_show
        show = Show.where(id: params[:id]).first

        if show.nil?
            render json: {code: 204, success: 'false', message: 'Title not found'}
        else
            auth = show.authenticate_for_json(request.headers['token'], request.headers['device'])

            if auth[:code] == 100
                data = Array.new
                episodes = Episode.where(show_id: show.id).order(episode_number: :desc)

                episodes.each do |episode|
                    item = Hash.new

                    item[:id] = "#{show.name.gsub(' ','_').gsub(/[^a-z0-9]/i,'')}#{episode.episode_number}#{episode.release_date.strftime('%-d-%B-%Y')}"
                    item[:title] = episode.title
                    item[:length] = 0
                    item[:episode_number] = episode.episode_number
                    item[:content_type] = show.content_type
                    item[:content_quality] = show.content_quality
                    item[:stream_format] = 'hls'
                    item[:stream_url] = "#{episode.stream_url}"
                    item[:bitrate] = show.bitrate

                    item[:actors] = show.actors.split(/\r\n/)
                    item[:genres] = show.genres.split(/\r\n/)
                    item[:synopsis] = episode.synopsis

                    data.push(item)
                end

                render json: {code: 100, success: true, message: 'Success', feed: data}
            else
                render json: auth
            end
        end
    end

    def view_movie
        movie = Movie.where(id: params[:id]).first

        if movie.nil?
            render json: {code: 204, success: false, message: 'Title not found'}
        else
            auth = show.authenticate_for_json(request.headers['token'], request.headers['device'])
            if auth[:code] == 100
                data = Hash.new

                data[:id] = "#{movie.name.gsub(' ','_').gsub(/[^a-z0-9]/i,'')}#{movie.created_at.strftime('%-d-%B-%Y')}"
                data[:title] = movie.name
                # TODO add movie length
                #data[:length] = 0
                data[:content_quality] = movie.content_quality
                data[:stream_format] = 'hls'
                data[:stream_url] = "#{movie.stream_url}"
                data[:bitrate] = movie.bitrate

                data[:actors] = movie.actors.split(/\r\n/)
                data[:genres] = movie.genres.split(/\r\n/)
                data[:synopsis] = movie.synopsis

                render json: {code: 100, success: true, message: 'Success', feed: data}
            else
                render json: auth
            end
        end
    end

    private

    def authenticate_for_grid(token, device_id)
        device = Device.where(id: device_id, serial: token).first

        if device.nil?
            return 204
        elsif device_id.expiry < Date.today
            return 206
        else
            return 100
        end
    end

    def generate_grid_search_params(grid, device)

        filter_params = Hash.new
        unless grid.content_type.blank?
            filter_params[:content_type] = grid.content_type
        end

        unless grid.content_quality.blank?
            filter_params[:content_quality] = grid.content_quality
        end

        filter_params[:free] = grid.free
        if device == 'ipad' || device == 'iphone' || device == 'ipod'
            filter_params[:ios] = true
        elsif device == 'android'
            filter_params[:android] = true
        elsif device == 'xbox'
            filter_params[:xbox] = true
        elsif device == 'playstation'
            filter_params[:playstation] = true
        elsif device == 'roku'
            filter_params[:roku] = true
        end

        return filter_params
    end

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
end
