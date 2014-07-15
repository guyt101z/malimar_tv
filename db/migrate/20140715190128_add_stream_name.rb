class AddStreamName < ActiveRecord::Migration
  def change
      add_column :channels, :stream_name, :string
      add_column :movies, :stream_name, :string
      add_column :episodes, :stream_name, :string
  end
end
