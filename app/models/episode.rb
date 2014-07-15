class Episode < ActiveRecord::Base
    attr_accessible :show_id, :title, :episode_number, :stream_url, :release_date, :synopsis, :length

    validates_presence_of :show_id, :title, :episode_number, :stream_url, :release_date, :length

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
