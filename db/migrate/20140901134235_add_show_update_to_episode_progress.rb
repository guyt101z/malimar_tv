class AddShowUpdateToEpisodeProgress < ActiveRecord::Migration
  def change
    add_column :episode_progresses, :show_progress_id, :integer
  end
end
