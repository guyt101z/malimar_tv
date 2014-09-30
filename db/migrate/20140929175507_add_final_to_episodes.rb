class AddFinalToEpisodes < ActiveRecord::Migration
  def change
    add_column :episodes, :final, :boolean
  end
end
