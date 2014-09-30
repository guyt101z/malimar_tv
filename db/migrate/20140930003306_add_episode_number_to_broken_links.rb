class AddEpisodeNumberToBrokenLinks < ActiveRecord::Migration
  def change
    add_column :broken_links, :episode_number, :integer
  end
end
