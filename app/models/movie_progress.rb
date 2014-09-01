class MovieProgress < ActiveRecord::Base
    attr_accessible :movie_id, :show_id, :time

    def watch_url
        movie = Movie.find(movie_id)
        return movie.watch_url
    end
end
