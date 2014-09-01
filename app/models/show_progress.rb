class ShowProgress < ActiveRecord::Base
    attr_accessible :show_id, :user_id, :episode_number

    def watch_url
        show = Show.find(show_id)
        episode = Episode.where(show_id: show.id, episode_number: episode_number).first

        return episode.watch_url
    end
end
