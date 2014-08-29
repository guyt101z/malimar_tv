class Show < ActiveRecord::Base
    attr_accessible :name, :free, :image, :roku, :ios, :android, :web, :rtmp_url, :grid_id, :slug

    validates_presence_of :name, :bitrate
    validates_inclusion_of :free, in: [true,false], message: 'must be selected'
    validates_inclusion_of :content_type, in: ['Audio','Video'], message: 'must be selected'
    validates_inclusion_of :content_quality, in: ['HD','SD'], message: 'must be selected'
    validates_numericality_of :bitrate

    mount_uploader :image, MovieImageUploader
    mount_uploader :banner, BannerUploader

    has_many :episodes

    searchkick

    before_validation :slug_change

    before_validation :slug_change

    def slug_change
        new_name = name.clone

        test_slug = "#{new_name.gsub(' ','-')}"
        other_channels = Channel.where(slug: test_slug)
        if other_channels.any?
            unless other_channels.first.id == id
                test_slug = "#{new_name.gsub(' ','-')}-#{id.to_s}-show"
            end
            self.slug = test_slug
        else
            self.slug = test_slug
        end

    end

    def latest_episode
        episodes = Episode.where(show_id: id)
        latest_ep = nil
        episodes.each do |ep|
            if latest_ep.nil? || ep.release_date > latest_ep
                latest_ep = ep.release_date
            end
        end
        return latest_ep.strftime('%B %-d, %Y')
    end

    def matches?(search_term)
        searchable_string = name.downcase
        if roku == true
            searchable_string += ' roku'
        end
        if ios == true
            searchable_string += ' ios'
        end
        if android == true
            searchable_string += ' android'
        end
        if web == true
            searchable_string += ' web'
        end
        if free == true
            searchable_string += ' free'
        else
            searchable_string += ' premium'
        end
        if searchable_string.include?(search_term.downcase)
            return true
        else
            if searchable_string.include?('roku') && search_term.include?('roku')
                return true
            elsif searchable_string.include?('web') && search_term.include?('web')
                return true
            elsif searchable_string.include?('ios') && search_term.include?('ios')
                return true
            elsif searchable_string.include?('android') && search_term.include?('android')
                return true
            else
                return false
            end
        end
    end

    def available?(device)
        if (device == 'roku' && roku == true) || (device == 'web' && web == true) || (device == 'android' && android == true) ||
            ((device == 'ipad' || device == 'iphone' || device == 'ipod') && ios == true)
            return true
        else
            return false
        end
    end

    def episode_count
        return Episode.where(show_id: id).count
    end

    def matches_genre?(search_genre)
        unless genres != nil && genres.downcase.include?(search_genre.downcase)
            return false
        else
            return true
        end
    end

    def watch_url
        return "/watch/shows/#{slug}"
    end

    def device_url
        return "/api/v1/json/show/#{id.to_s}"
    end

    def auth(token,type)
        if ['Roku','Ipad','Iphone','Ipod','Android'].include? type
            device = Device.where(serial: token, type: type).first

            if device.nil?
                return {success: false, code: 200, message: 'Invalid token'}
            else
                if device.is_active.nil? || device.is_active?
                    if type == 'Roku'
                        unless available?(type.downcase)
                            return {success: false, code: 202, message: 'Not available on this device'}
                        else
                            if free == false
                                if device.premium?
                                    if adult == true && device.adult == true
                                        return {success: true, code: 100, message: 'Success'}
                                    elsif adult == true && (device.adult.nil? || device.adult == false)
                                        return {success: false, code: 205, message: 'Device is not permitted to view Adult Content'}
                                    else
                                        return {success: true, code: 100, message: 'Success'}
                                    end
                                else
                                    return {success: false, code: 206, message: 'Device is not premium'}
                                end
                            else
                                if adult == true && device.adult == true
                                    return {success: true, code: 100, message: 'Success'}
                                elsif adult == true && (device.adult.nil? || device.adult == false)
                                    return {success: false, code: 205, message: 'Device is not permitted to view Adult Content'}
                                else
                                    return {success: true, code: 100, message: 'Success'}
                                end
                            end
                        end
                    else
                        user = User.find(device.user_id)
                        unless available?(type.downcase)
                            return {success: false, code: 202, message: 'Not available on this device'}
                        else
                            if free == false
                                if user.premium?
                                    if adult == true && device.adult == true
                                        return {success: true, code: 100, message: 'Success'}
                                    elsif adult == true && (device.adult.nil? || device.adult == false)
                                        return {success: false, code: 205, message: 'Device is not permitted to view Adult Content'}
                                    else
                                        return {success: true, code: 100, message: 'Success'}
                                    end
                                else
                                    return {success: false, code: 206, message: 'Device is not premium'}
                                end
                            else
                                if adult == true && device.adult == true
                                    return {success: true, code: 100, message: 'Success'}
                                elsif adult == true && (device.adult.nil? || device.adult == false)
                                    return {success: false, code: 205, message: 'Device is not permitted to view Adult Content'}
                                else
                                    return {success: true, code: 100, message: 'Success'}
                                end
                            end
                        end
                    end
                else
                    return {success: false, code: 211, message: 'Device has been suspended'}
                end
            end
        else
            return {success: false, code: 201, message: 'Invalid device type'}
        end
    end

    def roku_url
        return '/api/v1/roku/show/'+id.to_s+'?serial=SERIAL'
    end

    def newest_episode
        episodes = Episode.where(show_id: id).order(release_date: :desc)
        if episodes.any?
            return episodes.first.release_date.to_datetime.to_i
        else
            return 0
        end
    end

    def feed_type
        return 'Show'
    end
end
