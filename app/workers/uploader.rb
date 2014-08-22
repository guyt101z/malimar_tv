class Uploader
    @queue = :uploader

    def self.perform(grid_id)
        grid = Grid.find(grid_id)
        file = File.open("#{Rails.root}/public#{grid.file_url}")
        parsed_xml = Crack::XML.parse(file)['feed']
        parsed_xml['item'].each do |item|
            if grid.class_type == 'Channel'
                Resque.enqueue(ChannelParser, item, grid_id)
            elsif grid.class_type == 'Show'
                if item.has_key?('feed')
                    Resque.enqueue(ShowParser, item, grid_id)
                else
                    Resque.enqueue(MovieParser, item, grid_id)
                end
            elsif grid.class_type == 'Movie'
                if item.has_key?('feed')
                    Resque.enqueue(ShowParser, item, grid_id)
                else
                    Resque.enqueue(MovieParser, item, grid_id)
                end
            end
        end
    end
end
