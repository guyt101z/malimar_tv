class RokuApiController < ApplicationController
    def home_grid
        auth = authenticate_serial_no_title(request.headers['serial'], 'free')
        if auth.nil?
            categories = Category.where(front_page: true).order(rank: :asc)
            builder = Nokogiri::XML::Builder.new { |xml|
                xml.send(:'feed', code: 100, message: 'Success') {
                    xml.startIndex 0
                    xml.itemCount categories.count
                    xml.totalCount categories.count
                    categories.each do |grid|
                        xml.send(:'item') {
                            filter_params = generate_grid_search_params(grid)

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
                            xml.titleCount filtered_items.count
                            xml.title grid.name
                            xml.feed roku_view_grid_url(id: grid.id)
                        }
                    end
                }
            }
            render :xml => builder.to_xml
        else
            render :xml => auth
        end
    end

    def view_grid
        auth = authenticate_serial_no_title(request.headers['serial'], 'free')

        if auth[:code] == 100
            grid = Category.where(id: params[:id]).first
            if grid.nil?
                builder = Nokogiri::XML::Builder.new { |xml|
                    xml.send(:'feed', code: 204, message: 'Grid not found', success: false)
                }
            else
                filter_params = generate_grid_search_params(grid)

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
                builder = Nokogiri::XML::Builder.new { |xml|
                    xml.send(:'feed', auth){
                        xml.startIndex 0
                        xml.itemCount filtered_items.count
                        xml.totalCount filtered_items.count
                        filtered_items.each do |item|
                            xml.send(:'item', sdImg: root_url[0..-2]+item.image_url(:sd), hdImg: root_url[0..-2]+item.image_url(:hd)){
                                xml.title item.name
                                xml.feed root_url[0...-1]+item.roku_url, type: 'episodes'
                            }
                        end
                    }
                }
            end
        else
            builder = Nokogiri::XML::Builder.new { |xml|
                xml.send(:'feed', auth)
            }
        end
        render :xml => builder.to_xml
    end

    def view_movie
        movie = Movie.where(id: params[:id]).first
        if movie.nil?
            builder = Nokogiri::XML::Builder.new { |xml|
                xml.send(:'feed', code: 204, message: 'Title not found', success: false)
            }
        else
            auth = movie.authenticate(request.headers['serial'], 'roku')

            if auth[:code] == 100
                builder = Nokogiri::XML::Builder.new { |xml|
                    xml.send(:'feed', code: 100, message: 'Success') {
                        xml.send(:'item', sdImg: root_url[0..-2]+movie.image_url(:sd), hdImg: root_url[0..-2]+movie.image_url(:hd)){
                            xml.id "#{movie.name}#{movie.created_at.strftime('%-d-%B-%Y')}"
                            xml.title movie.name
                            # TODO xml.length movie.length
                            # TODO add release date to titles
                            xml.releaseDate movie.created_at.strftime('%-d-%B-%Y')
                            xml.contentType 'Video'
                            xml.contentQuality movie.content_quality
                            xml.streamFormat 'hls'
                            xml.send(:'media'){
                                xml.streamQuality movie.content_quality
                                xml.streamBitrate movie.bitrate
                                xml.streamUrl movie.stream_url
                            }
                            xml.switchingStrategy 'unaligned-segments'
                            xml.synopsis movie.synopsis
                            actor_list = movie.actors.split('\n')
                            xml.send(:'actors'){
                                actor_list.each do |actor|
                                    xml.actor actor
                                end
                            }
                            # TODO fix actor/genre splitting, maybe split at save and store as YAML?
                            genre_list = movie.genres.split('\n')
                            xml.send(:'genres'){
                                genre_list.each do |genre|
                                    xml.genre genre
                                end
                            }
                        }
                    }
                }
            else
                builder = Nokogiri::XML::Builder.new { |xml|
                    xml.send(:'feed', auth)
                }
            end
            render xml: builder.to_xml
        end
    end

    def view_channel
        channel = Channel.where(id: params[:id]).first

        if channel.nil?
            builder = Nokogiri::XML::Builder.new { |xml|
                xml.send(:'feed', code: 204, message: 'Title not found', success: false)
            }
        else
            auth = channel.authenticate(request.headers['serial'], 'roku')
            builder = Nokogiri::XML::Builder.new { |xml|
                if auth[:code] == 100
                    xml.send(:'feed', auth) {
                        xml.resultLength 1
                        xml.endIndex 1
                        xml.send(:'item', sdImg: root_url[0...-1]+channel.image_url(:sd), hdImg: root_url[0...-1]+channel.image_url(:hd)){
                            xml.id "#{channel.name}#{channel.created_at.strftime('%-d-%B-%Y')}"
                            xml.title channel.name
                            xml.length 0
                            xml.contentType channel.content_type
                            xml.contentQuality channel.content_quality
                            xml.streamFormat 'hls'
                            xml.send(:'media') {
                                xml.streamQuality channel.content_quality
                                xml.streamBitrate channel.bitrate
                                xml.streamUrl "#{channel.stream_url}?token=#{generate_token(channel.stream_name)}"
                            }
                            xml.switchingStrategy 'full-adaptation'
                            xml.synopsis channel.synopsis
                            actor_list = channel.actors.split(/\r\n/)
                            xml.send(:'actors'){
                                actor_list.each do |actor|
                                    xml.actor actor
                                end
                            }
                            # TODO fix actor/genre splitting, maybe split at save and store as YAML?
                            genre_list = channel.genres.split(/\r\n/)
                            xml.send(:'genres'){
                                genre_list.each do |genre|
                                    xml.genre genre
                                end
                            }
                        }
                    }
                else
                    xml.send(:'feed', auth)
                end
            }
        end

        render xml: builder.to_xml
    end

    def view_show
        show = Show.where(id: params[:id]).first

        if show.nil?
            builder = Nokogiri::XML::Builder.new { |xml|
                xml.send(:'feed', code: 204, message: 'Title not found', success: false)
            }
        else
            auth = show.authenticate(request.headers['serial'], 'roku')

            if auth[:code] == 100
                episodes = Episode.where(show_id: show.id).order(episode_number: :desc)
                builder = Nokogiri::XML::Builder.new { |xml|
                    xml.send(:'feed', auth) {
                        xml.resultLength episodes.count
                        xml.endIndex episodes.count

                        episodes.each do |episode|
                            xml.send(:'item', sdImg: root_url[0..-2]+show.image_url(:sd), hdImg: root_url[0..-2]+show.image_url(:hd)){
                                xml.id "#{show.name}#{episode.episode_number}#{show.created_at.strftime('%-d-%B-%Y')}"
                                xml.title episode.title
                                # TODO xml.length movie.length
                                # TODO add release date to titles
                                xml.releaseDate episode.release_date.strftime('%-d-%B-%Y')
                                xml.contentType 'Video'
                                xml.contentQuality show.content_quality
                                xml.streamFormat 'hls'
                                xml.send(:'media'){
                                    xml.streamQuality show.content_quality
                                    xml.streamBitrate show.bitrate
                                    xml.streamUrl episode.stream_url
                                }
                                xml.switchingStrategy 'unaligned-segments'
                                xml.synopsis episode.synopsis
                                actor_list = show.actors.split('\n')
                                xml.send(:'actors'){
                                    actor_list.each do |actor|
                                        xml.actor actor
                                    end
                                }
                                # TODO fix actor/genre splitting, maybe split at save and store as YAML?
                                genre_list = show.genres.split('\n')
                                xml.send(:'genres'){
                                    genre_list.each do |genre|
                                        xml.genre genre
                                    end
                                }
                            }
                        end
                    }
                }
            else
                builder = Nokogiri::XML::Builder.new { |xml|
                    xml.send(:'feed', auth)
                }
            end
        end
        render xml: builder.to_xml
    end

    private

    def authenticate_serial_no_title(serial)
        roku = Roku.where(serial: serial).first

        if roku.nil?
            builder = Nokogiri::XML::Builder.new { |xml|
                xml.send(:'feed', code: 200, message: 'Serial not found/valid')
            }
            return builder.to_xml
        else
            return nil
        end
    end

    def generate_grid_search_params(grid)

        filter_params = Hash.new
        unless grid.content_type.blank?
            filter_params[:content_type] = grid.content_type
        end

        unless grid.content_quality.blank?
            filter_params[:content_quality] = grid.content_quality
        end

        filter_params[:free] = grid.free
        filter_params[:roku] = true

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
