class Episode < ActiveRecord::Base
    attr_accessible :show_id, :title, :episode_number, :stream_url, :release_date, :synopsis, :length

    validates_presence_of :show_id, :title, :episode_number, :stream_url, :release_date, :length

    belongs_to :channel

    def matches?(search_term)
        searchable_string = title.downcase
        if searchable_string.include?(search_term.downcase)
            return true
        else
            return false
        end
    end

    def watch_url
        return "/watch/shows/#{show_id}/#{episode_number}"
    end
end
