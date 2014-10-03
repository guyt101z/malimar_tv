class Episode < ActiveRecord::Base
    attr_accessible :show_id, :title, :episode_number, :release_date, :synopsis, :length

    validates_presence_of :show_id, :episode_number, :release_date, :length

    belongs_to :show

    def matches?(search_term)
        searchable_string = title.downcase
        if searchable_string.include?(search_term.downcase)
            return true
        else
            return false
        end
    end

    def watch_url
        show = Show.find(show_id)
        return "/watch/shows/#{show.slug}/#{episode_number}"
    end

    def last_episode?
        later_episodes = Episode.where(show_id: show_id).where('episode_number > ?', episode_number)

        if later_episodes.any?
            return false
        else
            return true
        end
    end

    def next_episode
        later_episodes = Episode.where(show_id: show_id).where('episode_number > ?', episode_number).order(episode_number: :asc)

        if later_episodes.any?
            return later_episodes.first.episode_number
        else
            return nil
        end
    end

    def added_by_admin
        if added_by.present?
            admin = Admin.where(id: added_by).first
            if admin.nil?
                return '[DELETED]'
            else
                return admin.name
            end
        else
            return 'Migration'
        end
    end

    def edited_by_admin
        if edited_by.present?
            admin = Admin.where(id: edited_by).first
            if admin.nil?
                return '[DELETED]'
            else
                return admin.name
            end
        else
            return 'Not Edited'
        end
    end

    def hls_stream
        filename = show.name.gsub(/[^a-z0-9]/i, '')

        if show.add_ep_num?
            filename += "-#{episode_number.to_s}"
        end
        if show.add_date?
            filename += "-#{release_date.strftime('%-d-%b-%Y')}"
        end

        if show.disable_playlist?
            if show.hls_stream.end_with?('/')
                return "#{show.hls_stream}#{filename}"
            else
                return "#{show.hls_stream}/#{filename}"
            end
        else
            if show.hls_stream.end_with?('/')
                return "#{show.hls_stream}#{filename}/playlist.m3u8"
            else
                return "#{show.hls_stream}/#{filename}/playlist.m3u8"
            end
        end
    end

    def rtmp_stream
        filename = show.name.gsub(/[^a-z0-9]/i, '')

        if show.add_ep_num?
            filename += "-#{episode_number.to_s}"
        end
        if show.add_date?
            filename += "-#{release_date.strftime('%-d-%b-%Y')}"
        end

        if show.rtmp_stream.end_with?('/')
            return "#{show.rtmp_stream}#{filename}"
        else
            return "#{show.rtmp_stream}/#{filename}"
        end
    end
end
