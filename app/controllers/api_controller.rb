class ApiController < ApplicationController
    def home
        channels = Channel.where(params[:device].to_sym => true)
        builder = Nokogiri::XML::Builder.new { |xml|
            xml.send(:'feed') {
                xml.startIndex 0
                xml.itemCount channels.count
                xml.totalCount channels.count
                channels.each do |channel|
                    xml.send(:'item') {
                        xml.title channel.name
                        xml.feed api_channel_url(device: params[:device], channel_id: channel.id)
                        unless channel.free? || params[:device] != 'roku'
                            xml.authorizationURL api_authorize_roku_url(serial: 'SERIAL')
                        end
                    }
                end
            }
        }
        render :xml => builder.to_xml
    end

    def tv_show
        show = Show.find(params[:show_id])
        if show.available?(params[:device])
            episodes = Episode.where(show_id: show.id).order(episode_number: :desc)
            builder = Nokogiri::XML::Builder.new { |xml|
                xml.send(:'feed') {
                    xml.resultLength episodes.count
                    xml.endIndex episodes.count
                    episodes.each do |episode|

                        xml.send(:'item', hdImg: root_url.chop+show.image_url(:hd), sdImg: root_url.chop+show.image_url(:sd)){
                            xml.id episode.id
                            xml.title episode.title
                            xml.length episode.length
                            xml.episodeNumber episode.episode_number
                            xml.releaseDate episode.release_date.strftime('%d-%B-%Y')
                            xml.contentQuality episode.content_quality
                            xml.streamFormat 'hls'
                            if channel.live?
                                xml.live 'True'
                                xml.SwitchingStrategy 'full-adaptation'
                            else
                                xml.SwitchingStrategy 'unaligned-segments'
                            end
                            xml.send(:'media') {
                                xml.streamQuality episode.content_quality
                                xml.streamBitrate episode.bitrate
                                xml.streamUrl episode.stream_url
                            }
                            xml.synopsis episode.synopsis
                            if episode.actors.present?
                                actors = episode.actors.split('\n')
                                xml.send(:'actors') {
                                    actors.each do |actor|
                                        xml.actor actor
                                    end
                                }
                            end
                            if episode.genres.present?
                                genres = episode.genres.split('\n')
                                xml.send(:'genres') {
                                    genres.each do |genre|
                                        xml.genre genre
                                    end
                                }
                            end
                        }
                    end
                }
            }
            render :xml => builder.to_xml
        else
            render(:file => File.join(Rails.root, 'public/500.html'), :status => 500, :layout => false)
        end
    end

    def channel
        channel = Channel.find(params[:channel_id])
        if channel.available?(params[:device])
            episodes = Episode.where(channel_id: channel.id).order(episode_number: :desc)
            builder = Nokogiri::XML::Builder.new { |xml|
                xml.send(:'feed') {
                    xml.resultLength episodes.count
                    xml.endIndex episodes.count
                    episodes.each do |episode|

                        xml.send(:'item', hdImg: root_url.chop+channel.image_url(:hd), sdImg: root_url.chop+channel.image_url(:sd)){
                            xml.id episode.id
                            xml.title episode.title
                            xml.length episode.length
                            xml.episodeNumber episode.episode_number
                            xml.releaseDate episode.release_date.strftime('%d-%B-%Y')
                            xml.contentQuality episode.content_quality
                            xml.streamFormat 'hls'
                            if channel.live?
                                xml.live 'True'
                                xml.SwitchingStrategy 'full-adaptation'
                            else
                                xml.SwitchingStrategy 'unaligned-segments'
                            end
                            xml.send(:'media') {
                                xml.streamQuality episode.content_quality
                                xml.streamBitrate episode.bitrate
                                xml.streamUrl episode.stream_url
                            }
                            xml.synopsis episode.synopsis
                            if episode.actors.present?
                                actors = episode.actors.split('|')
                                xml.send(:'actors') {
                                    actors.each do |actor|
                                        xml.actor actor
                                    end
                                }
                            end
                            if episode.genres.present?
                                genres = episode.genres.split('|')
                                xml.send(:'genres') {
                                    genres.each do |genre|
                                        xml.genre genre
                                    end
                                }
                            end
                        }
                    end
                }
            }
            render :xml => builder.to_xml
        else
            render(:file => File.join(Rails.root, 'public/500.html'), :status => 500, :layout => false)
        end
    end

    def authorize_roku
        device = Roku.where(serial: params[:serial]).first
        if device.nil?
            render(:file => File.join(Rails.root,'public/404.html'), status: 404, layout: false)
        else
            user = User.where(id: device.user_id).first
            if user.nil?
                render(:file => File.join(Rails.root,'public/500.html'), status: 500, layout: false)
            else
                if user.expiry >= Date.today
                    render status: 200
                else
                    render(:file => File.join(Rails.root,'public/403.html'), status: 403, layout: false)
                end
            end
        end
    end
end
