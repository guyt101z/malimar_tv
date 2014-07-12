class Channel < ActiveRecord::Base
    attr_accessible :name, :live, :free, :image, :roku, :ios, :android, :web

    validates_presence_of :name
    validates_inclusion_of :live, in: [true,false], message: 'must be selected'
    validates_inclusion_of :free, in: [true,false], message: 'must be selected'

    mount_uploader :image, MovieImageUploader

    has_many :episodes

    searchable do
        text :name
        boolean :web
    end

    def matches?(search_term)
        searchable_string = name.downcase
        if live == true
            searchable_string += ' live'
        end
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
end
