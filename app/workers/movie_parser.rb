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

            if item['rating'] == 'Rated R'
                movie.adult = true
            else
                movie.adult = false
            end
            movie.content_quality = item['media']['streamQuality']
            movie.stream_url = item['media']['streamUrl']
            movie.bitrate = item['media']['streamBitrate']
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
