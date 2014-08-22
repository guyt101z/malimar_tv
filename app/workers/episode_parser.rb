class EpisodeParser
    @queue = :episode_parser
    def self.perform(show_id, link, grid_id)
        migration_item = VodMigrationItem.create(status: 'In Progress',completed: false, migration_id: grid_id)
        begin
            show = Show.find(show_id)

            response = HTTParty.get(link)
            parsed_xml = Crack::XML.parse(response.body)['feed']

            parsed_xml['item'].each do |item|
                episode = Episode.new
                episode.title = item['title']
                episode.show_id = show_id
                episode.episode_number = item['episodeNumber'].to_i
                episode.length = item['length'].to_i
                episode.release_date = Date.strptime(item['releaseDate'], "%d-%B-%Y")
                episode.stream_url = item['media']['streamUrl']
                if episode.save(:validate => false)
                    migration_item.status = 'Complete'
                    migration_item.completed = true
                    migration_item.save
                else
                    migration_item.status = 'Error'
                    migration_item.completed = true
                    migration_item.error = 'Episode could not be saved: '+ episode.errors.full_messages.join(", ")
                    migration_item.save
                end
            end
        rescue => e
            migration_item.status = 'Error'
            migration_item.completed = true
            migration_item.error = 'Exception raised (Episode): '+ e.message
            migration_item.save
        end
    end
end
