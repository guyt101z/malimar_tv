class Movie < ActiveRecord::Base
    attr_accessible :name, :live, :free, :image, :roku, :ios, :android, :web, :stream_url, :rtmp_url, :release_date, :length

    validates_presence_of :name, :stream_url, :release_date, :length
    validates_inclusion_of :free, in: [true,false], message: 'must be selected'
    validates_inclusion_of :content_quality, in: ['HD','SD'], message: 'must be selected'
    validates_numericality_of :bitrate

    mount_uploader :image, MovieImageUploader
    mount_uploader :banner, BannerUploader

    has_many :episodes

    searchkick

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

    def matches_category?(params)
        matches = true
        if params.has_key?(:genre)
            unless genres.include?(params[:genre])
                matches = false
            end
        end
        if params.has_key?(:content_type)
            # Movies are always video
        end
        if params.has_key?(:content_quality)
            unless params[:content_quality] == content_quality
                matches = false
            end
        end
        if params.has_key?(:free)
            unless params[:free] == free
                matches = false
            end
        end
        return matches
    end

    def watch_url
        return "/watch/movies/#{id}"
    end

    def device_url
        return "/api/v1/json/movie/#{id.to_s}"
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
        return '/api/v1/roku/movie/'+id.to_s+'?serial=SERIAL'
    end
end
