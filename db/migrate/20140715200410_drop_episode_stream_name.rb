class DropEpisodeStreamName < ActiveRecord::Migration
  def change
      remove_column :episodes, :stream_name
  end
end
