class AddAvailabilityToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :roku, :boolean
    add_column :channels, :ios, :boolean
    add_column :channels, :android, :boolean
    add_column :channels, :web, :boolean
  end
end
