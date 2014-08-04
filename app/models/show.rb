class Show < ActiveRecord::Base
    attr_accessible :name, :free, :image, :roku, :ios, :android, :web, :rtmp_url

    validates_presence_of :name, :bitrate
    validates_inclusion_of :free, in: [true,false], message: 'must be selected'
    validates_inclusion_of :content_type, in: ['Audio','Video'], message: 'must be selected'
    validates_inclusion_of :content_quality, in: ['HD','SD'], message: 'must be selected'
    validates_numericality_of :bitrate

    mount_uploader :image, MovieImageUploader
    mount_uploader :banner, BannerUploader

    has_many :episodes

    searchkick

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
        if (device == 'roku' && roku == true) || (device == 'web' && web == true) || (device == 'android' && android == true) || (device == 'ios' && ios == true)
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
        return "/watch/shows/#{id}"
    end

    def device_url
        return "/api/v1/json/show/#{id.to_s}"
    end

    def authenticate(token_serial, device_type)

        if (ios == true && (device_type == 'ipad' || device_type == 'iphone' || device_type == 'ipod')) ||
           (android == true && device_type == 'android') ||
           # (xbox == true && device_type == 'xbox') ||
           # (playstation == true && device_type == 'playstation') ||
           (roku == true && device_type == 'roku')
            case device_type

            # iOS devices
            when 'ipad'
                device = Ipad.where(serial: token_serial).first

            when 'iphone'
                device = Iphone.where(serial: token_serial).first

            when 'ipod'
                device = Ipod.where(serial: token_serial).first

            # Android
            when 'android'
                device = Android.where(serial: token_serial).first

            # Xbox
            when 'xbox'
                device = Xbox.where(serial: token_serial).first

            # Playstation
            when 'playstation'
                device = Playstation.where(serial: token_serial).first

            when 'roku'
                device = Roku.where(serial: token_serial).first
            else
                return {code: 205, message: 'Invalid device type', success: false}
            end

            unless device.nil?
                if free == false
                    user = User.where(id: device.user_id).first
                    unless user.nil?
                        if user.expiry.nil? || user.expiry < Date.today
                            return {code: 202, message: 'Account is not premium', success: false}
                        else
                            return {code: 100, message: 'Success', success: true}
                        end
                    else
                        return {code: 201, message: 'Token/serial not valid', success: false}
                    end
                else
                    return {code: 100, message: 'Success', success: true}
                end
            else
                return {code: 201, message: 'Token/serial not valid', success: false}
            end
        else
            return {code: 203, message: 'Title not available on this device', success: false}
        end

    end

    def authenticate_for_json(token, device_id)
        device = Device.where(id: device_id, serial: token).first

        if device.nil?
            return {code: 201, message: 'Token not valid', success: false}
        elsif device.expiry.nil? || device.expiry < Date.today
            return {code: 206, message: 'Expired token', success: false}
        elsif available?(device.type.downcase) == false
            return {code: 203, message: 'Title not available on this device', success: false}
        else
            if free == false
                user = User.where(id: device.user_id).first
                unless user.nil?
                    if user.expiry.nil? || user.expiry < Date.today
                        return {code: 202, message: 'Account is not premium', success: false}
                    else
                        return {code: 100, message: 'Success', success: true}
                    end
                else
                    return {code: 201, message: 'Token/serial not valid', success: false}
                end
            else
                return {code: 100, message: 'Success', success: true}
            end
        end
    end

    def roku_url
        return '/api/v1/roku/show/'+id.to_s+'?serial=SERIAL'
    end
end
