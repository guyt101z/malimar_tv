class MovieParser
    @queue = :movie_parser
    def self.perform(item, grid_id)
        migration_item = VodMigrationItem.create(status: 'In Progress',completed: false, migration_id: migration_id)
        begin
            grid = Grid.find(grid_id)
            movie = Movie.new
            movie.grid_id = grid_id

            movie.name = item['title']
            movie.free = free
            movie.synopsis = item['synopsis']
            movie.release_date = Date.strptime(item['releaseDate'], "%d-%B-%Y")

            new_name = movie.name.clone

            test_slug = "#{new_name.gsub(' ','-')}"
            other_movies = Movie.where(slug: test_slug)
            if other_movies.any?
                test_slug = "#{new_name.gsub(' ','-')}-#{id.to_s}-movie"
                movie.slug = test_slug
            else
                movie.slug = test_slug
            end

            if item['rating'] == 'Rated R'
                movie.adult = true
            else
                movie.adult = false
            end
            if item.has_key?('media')
                media = item['media'].to_hash

                movie.content_quality = item['media']['streamQuality']
                movie.stream_url = item['media']['streamUrl']
                if movie.stream_url.start_with?('http://')
                    movie.stream_url.gsub!('http://','')
                end
                if movie.stream_url.end_with?('rtmp://')
                    movie.stream_url.gsub!('rtmp://','')
                end

                movie.bitrate = item['media']['streamBitrate']
            end
            movie.length = 0
            movie.genres = ""

            unless item['genres']['genre'].blank?
                item['genres']['genre'].each do |genre|
                    unless genre.nil?
                        movie.genres += "#{genre}\r\n"
                    end
                end
            end

            movie.actors = ""

            unless item['actors']['actor'].blank?
                item['actors']['actor'].each do |actor|
                    unless actor.nil?
                        movie.actors += "#{actor}\r\n"
                    end
                end
            end

            movie.roku = true
            movie.web = true
            movie.ios = true
            movie.android = true

            movie.remote_image_url = item['hdImg']
            if movie.save
                GridItem.create(grid_id: grid_id, video_id: movie.id, video_type: 'Movie')
                migration_item.status = 'Complete'
                migration_item.completed = true
                migration_item.save
            else
                migration_item.status = 'Error'
                migration_item.completed = true
                migration_item.error = 'Movie could not be saved: '+movie.errors.full_messages.join(', ')
                migration_item.save
            end
        rescue => e
            migration_item.status = 'Error'
            migration_item.completed = true
            migration_item.error = 'Exception raised (Movie): '+ e.message
            migration_item.save
        end
    end
end
