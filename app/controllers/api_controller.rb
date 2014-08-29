class ApiController < ApplicationController
    def authenticate
        begin
            user = User.authenticate(request.headers['email'], request.headers['password'])

            if user.nil?
                render json: {code: 207, success: false, message: 'Invalid username or password'}
            else
                if request.headers['token'].present?
                    device = Device.where(user_id: user.id, serial: request.headers['token'], type: request.headers['devicetype']).first
                    if device.nil?
                        if user.max_devices?
                            render json: {code: 208, success: false, message: 'New device could not be created: user has reached maximum'}
                        else
                            unless request.headers['devicetype'] == 'Roku'
                                device = Device.new
                                device.user_id = user.id
                                device.type = request.headers['devicetype']
                                device.serial = SecureRandom.hex(10)

                                i = 0
                                until device.save || i > 50
                                    device.serial = SecureRandom.hex(10)
                                    i += 1
                                end

                                if i > 100
                                    render json: {code: 211, success: false, message: 'Timeout'}
                                else
                                    device.expiry = Date.today + 90.days
                                    device.save
                                    render json: {code: 103, success: true, message: 'New device and new token', token: device.serial}
                                end
                            else
                                render json: {code: 210, success: false, message: 'Roku has not been registered'}
                            end
                        end
                    else
                        if device.expired?
                            device.serial = SecureRandom.hex(10)

                            i = 0
                            until device.save || i > 50
                                device.serial = SecureRandom.hex(10)
                                i += 1
                            end

                            if i > 100
                                render json: {code: 211, success: false, message: 'Timeout'}
                            else
                                device.expiry = Date.today + 90.days
                                device.save
                                render json: {code: 102, success: true, message: 'New token', token: device.serial}
                            end
                        else
                            render json: {code: 101, success: true, message: 'No new token needed'}
                        end
                    end
                else
                    if request.headers['devicetype'].present? && request.headers['devicetype'] != 'Roku'
                        unless user.max_devices?
                            device = Device.new
                            device.user_id = user.id
                            device.type = request.headers['devicetype']
                            device.serial = SecureRandom.hex(10)

                            i = 0
                            until device.save || i > 50
                                device.serial = SecureRandom.hex(10)
                                i += 1
                            end

                            if i > 100
                                render json: {code: 211, success: false, message: 'Timeout'}
                            else
                                device.expiry = Date.today + 90.days
                                device.save
                                render json: {code: 103, success: true, message: 'New device and new token', token: device.serial}
                            end
                        else
                            render json: {code: 208, success: false, message: 'New device could not be created: user has reached maximum'}
                        end
                    elsif request.headers['devicetype'] == 'Roku'
                        render json: {code: 210, success: false, message: 'Roku must be registered on Malimar.tv'}
                    else
                        render json: {code: 201, success: false, message: 'Invalid/no device type passed'}
                    end
                end
            end
        rescue => e
            render json: {code: 209, success: false, message: 'Unknown error: ' + e.message}
        end
    end

    def home_grid
        begin
            auth = authenticate_for_grid(request.headers['token'], request.headers['devicetype'])


            unless auth[:code] == 100
                render json: auth
            else
                feed = {item_count: 0, items: []}

                grids = Grid.where(home_page: true).order(weight: :desc)
                device = Device.where(serial: request.headers['token']).first

                grids.each do |grid|
                    if (device.adult == true && grid.adult == true) || (grid.adult.nil? || grid.adult == false)
                        items = generate_grid(request.headers['devicetype'], device, grid)
                        count = items[:child_grids].count + items[:items].count
                        feed[:items].push({type: grid.feed_type, sd_img: root_url[0...-1]+grid.image_url(:sd), hd_img: root_url[0...-1]+grid.image_url(:hd),
                                           title: grid.name, feed: json_view_grid_url(id: grid.id)})
                    end
                end

                feed[:item_count] = grids.count
                auth[:feed] = feed
                render json: auth
            end
        rescue => e
            render json: {code: 209, success: false, message: 'Unknown error: ' + e.message}
        end
    end

    def view_grid
        begin
            auth = authenticate_for_grid(request.headers['token'], request.headers['devicetype'])


            unless auth[:code] == 100
                render json: auth
            else
                grid = Grid.where(id: params[:id]).first
                if grid.nil?
                    render json: {code: 203, success: false, message: 'Grid not found'}
                else
                    user = User.find(Device.where(serial: request.headers['token']).first.user_id)

                    items = generate_grid(request.headers['devicetype'], user, grid)

                    feed = {item_count: items[:child_grids].count + items[:items].count, items: []}

                    items[:child_grids].each do |item|
                        feed[:items].push({type: item.feed_type, sd_img: root_url[0...-1]+item.image_url(:sd), hd_img: root_url[0...-1]+item.image_url(:hd),
                                           title: item.name, feed: json_view_grid_url(id: item.id)})
                    end

                    items[:items].each do |item|
                        feed[:items].push({type: item.feed_type, sd_img: root_url[0...-1]+item.image_url(:sd), hd_img: root_url[0...-1]+item.image_url(:hd),
                                           title: item.name, feed: root_url[0...-1]+item.device_url})
                    end

                    auth[:feed] = feed
                    render json: auth
                end
            end
        rescue => e
            render json: {code: 209, success: false, message: 'Unknown error: ' + e.message}
        end
    end

    def view_channel
        begin
            channel = Channel.where(id: params[:id]).first

            if channel.nil?
                render json: {code: 203, success: false, message: 'Title not found.'}
            else
                auth = channel.auth(request.headers['token'], request.headers['devicetype'])

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

                    auth[:feed] = data
                    render json: auth
                else
                    render json: auth
                end
            end
        rescue => e
            render json: {code: 209, success: false, message: 'Unknown error: ' + e.message}
        end
    end

    def view_show
        begin
            show = Show.where(id: params[:id]).first

            if show.nil?
                render json: {code: 203, success: 'false', message: 'Title not found'}
            else
                auth = show.auth(request.headers['token'], request.headers['devicetype'])

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

                    auth[:feed] = data
                    render json: auth
                else
                    render json: auth
                end
            end
        rescue => e
            render json: {code: 209, success: false, message: 'Unknown error: ' + e.message}
        end
    end

    def view_movie
        begin
            movie = Movie.where(id: params[:id]).first

            if movie.nil?
                render json: {code: 204, success: false, message: 'Title not found'}
            else
                auth = show.auth(request.headers['token'], request.headers['device'])
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

                    auth[:feed] = data
                    render json: auth
                else
                    render json: auth
                end
            end
        rescue => e
            render json: {code: 209, success: false, message: 'Unknown error: ' + e.message}
        end
    end

    private

    def authenticate_for_grid(token, device)
        if ['Ipad','Iphone','Ipod','Android','Roku'].include? device
            user_device = Device.where(serial: token, type: device).first

            if device != 'Roku' && user_device.nil?
                return {code: 200, success: false, message: 'Invalid token'}
            elsif device != 'Roku' && user_device.expired? || user_device.nil?
                return {code: 200, success: false, message: 'Expired token'}
            else
                if user_device.nil? == false && user_device.is_active?
                    return {code: 100, success: true, message: 'Success'}
                elsif user_device.nil? == false && user_device.is_active? == false
                    return {code: 211, success: false, message: 'Device has been suspended'}
                else
                    return {code: 200, success: false, message: 'Expired token'}
                end
            end
        else
            return {code: 201, success: false, message: 'Invalid device type'}
        end
    end

    def generate_grid(devicetype, device, grid)
        if ['Iphone','Ipod','Ipad'].include? devicetype
            filter_params = {ios: true}
        else
            filter_params = {devicetype.downcase.to_sym => true}
        end
        if device.adult == true
            filter_params[:adult] = true
        else
            filter_params[:adult] = false
        end
        filter_params[:grid_id] = grid.id

        if grid.class_type == 'Show'
            items = Show.where(filter_params)
        elsif grid.class_type == 'Channel'
            if grid.sort == 'Alphabetical'
                items = Channel.where(filter_params).order(name: :asc)
            elsif grid.sort == 'Random'
                items = Channel.where(filter_params).shuffle
            elsif grid.sort == 'New Arrivals/Episodes'
                items = Channel.where(filter_params).order(created_at: :desc)
            end
        elsif grid.class_type == 'Movie'
            if grid.sort == 'Alphabetical'
                items = Movie.where(filter_params).order(name: :asc)
            elsif grid.sort == 'Random'
                items = Movie.where(filter_params).shuffle
            elsif grid.sort == 'New Arrivals/Episodes'
                items = Movie.where(filter_params).order(created_at: :desc)
            end
        end

        child_grids = Grid.where(filter_params.except(:ios, :android, :roku))

        return {child_grids: child_grids, items: items}
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
