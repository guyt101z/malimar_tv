class BrokenLink < ActiveRecord::Base
    attr_accessible :user_id, :video_id, :video_type, :episode_number

    validates_presence_of :user_id, :video_id, :video_type

    def self.already_submitted?(video_id, video_type, user_id, episode_number)
        if video_type == 'Show'
            link = BrokenLink.where(video_id: video_id, video_type: video_type, user_id: user_id, episode_number: episode_number).first
        else
            link = BrokenLink.where(video_id: video_id, video_type: video_type, user_id: user_id).first
        end

        if link.nil?
            return false
        else
            return true
        end
    end

end
