class GridItem < ActiveRecord::Base
    attr_accessible :video_id, :video_type, :grid_id

    validates_presence_of :video_id, :video_type, :grid_id

    belongs_to :grid

    def self.clear_shows
        GridItem.all.each do |gi|
            if gi.video.nil?
                gi.destroy
            end
        end
    end

    def video
        if video_type == 'Channel'
            return Channel.where(id: video_id).first
        elsif video_type == 'Movie'
            return Movie.where(id: video_id).first
        elsif video_type == 'Show'
            return Show.where(id: video_id).first
        else
            return nil
        end
    end
end
