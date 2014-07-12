class Episode < ActiveRecord::Base
    attr_accessible :channel_id, :title, :episode_number, :stream_url, :release_date, :content_type, :content_quality, :bitrate, :actors, :genres, :synopsis, :length

    validates_presence_of :channel_id, :title, :episode_number, :stream_url, :release_date, :bitrate, :length
    validates_inclusion_of :content_type, in: ['Audio','Video'], message: 'must be selected'
    validates_inclusion_of :content_quality, in: ['HD','SD'], message: 'must be selected'

    belongs_to :channel

    def matches?(search_term)
        searchable_string = title.downcase
        if content_quality == 'HD'
            searchable_string += ' HD'
        else
            searchable_string += ' SD'
        end
        if searchable_string.include?(search_term.downcase)
            return true
        else
            if searchable_string.include?('HD') && search_term.include?('HD')
                return true
            elsif searchable_string.include?('SD') && search_term.include?('SD')
                return true
            else
                return false
            end
        end
    end
end
