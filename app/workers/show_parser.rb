class ShowParser
    @queue = :show_parser
    def self.perform(item,grid_id)
        migration_item = VodMigrationItem.create(status: 'In Progress',completed: false, migration_id: grid_id)
        begin
            grid = Grid.find(grid_id)
            show = Show.new
            show.grid_id = grid_id
            show.name = item['title']
            show.free = grid.free
            show.synopsis = item['description']

            show.adult = grid.adult
            show.content_type = 'Video'
            show.content_quality = 'SD'
            show.bitrate = 0

            new_name = show.name.clone

            test_slug = "#{new_name.gsub(' ','-')}"
            other_shows = Show.where(slug: test_slug)
            if other_shows.any?
                test_slug = "#{new_name.gsub(' ','-')}-#{id.to_s}-show"
                show.slug = test_slug
            else
                show.slug = test_slug
            end

            show.roku = true
            show.web = true
            show.ios = true
            show.android = true

            show.remote_image_url = item['hdImg']

            if Show.where(name: show.name).count < 1
                if show.save
                    Resque.enqueue(EpisodeParser, show.id, item['feed'], grid_id)
                    migration_item.status = 'Complete'
                    migration_item.completed = true
                    migration_item.save
                else
                    migration_item.status = 'Error'
                    migration_item.completed = true
                    migration_item.error = 'Show could not be saved: '+ show.errors.full_messages.join(", ")
                    migration_item.save
                end
            else
                migration_item.status = 'Error'
                migration_item.completed = true
                migration_item.error = 'Show could not be saved: Duplicate Entry'
                migration_item.save
            end
        rescue => e
            migration_item.status = 'Error'
            migration_item.completed = true
            migration_item.error = 'Exception raised (Show): '+ e.message
            migration_item.save
        end
    end
end
