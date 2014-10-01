class AddUrlDataToShows < ActiveRecord::Migration
  def change
    add_column :shows, :add_date, :boolean
    add_column :shows, :add_ep_num, :boolean
    add_column :shows, :disable_playlist, :boolean
  end
end
