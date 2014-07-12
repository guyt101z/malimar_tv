class RokuApiController < ApplicationController
    def index
        builder = Nokogiri::XML::Builder.new { |xml|
            xml.send(:'feed') {
                xml.send(:'item', sdImg: "http://malimar.tv/malimar_images/2PhuYingYai.jpg", hdImg: "http://malimar.tv/malimar_images/2PhuYingYaiHD.jpg") {
                    xml.send(:'id', '2PhuYingYai211-Jan-2014')
                    xml.send(:'title', '2PhuYingYai | Episode 21  | Jan 01, 2014')
                    xml.send(:'length', 0)
                    xml.send(:'episodeNumber', 21)
                    xml.send(:'releaseDate', '1-Jan-2014')
                    xml.send(:'contentType', 'Video')
                    xml.send(:'contentQuality', 'SD')
                    xml.send(:'streamFormat', 'hls')
                    xml.send(:'media') {
                        xml.send(:'streamQuality', 'SD')
                        xml.send(:'streamBitrate', 700)
                        xml.send(:'streamUrl', 'http://vodplay2.malimarcdn.com/ThaiDrama11/_definst_/mp4:2PhuYingYai/2PhuYingYai-21.mp4/playlist.m3u8')
                    }
                    xml.send(:'SwitchingStrategy', 'unaligned-segments')
                    xml.send(:'actors') {
                        xml.send(:'actor', 'Episode 21')
                    }
                    xml.send(:'synopsis')
                    xml.send(:'genres') {
                        xml.send(:'genre', 'Drama')
                    }
                }
            }
        }
        render :xml => builder.to_xml
    end
end
