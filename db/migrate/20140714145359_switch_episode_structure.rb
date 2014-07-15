class SwitchEpisodeStructure < ActiveRecord::Migration
    def change
        add_column :episodes, :show_id, :integer
        remove_column :episodes, :channel_id, :integer

        add_column :channels, :stream_url, :string
        add_column :channels, :genres, :text
        add_column :channels, :actors, :text
    end
end
