class AddAvailabilityToShows < ActiveRecord::Migration
    def change
        add_column :shows, :roku, :boolean
        add_column :shows, :web, :boolean
        add_column :shows, :ios, :boolean
        add_column :shows, :android, :boolean
    end
end
