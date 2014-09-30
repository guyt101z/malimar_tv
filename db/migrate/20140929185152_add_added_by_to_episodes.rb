class AddAddedByToEpisodes < ActiveRecord::Migration
  def change
    add_column :episodes, :added_by, :integer
    add_column :episodes, :edited_by, :integer
  end
end
