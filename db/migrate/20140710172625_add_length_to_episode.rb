class AddLengthToEpisode < ActiveRecord::Migration
  def change
    add_column :episodes, :length, :integer
  end
end
