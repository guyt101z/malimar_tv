class AddGridIdToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :grid_id, :integer
  end
end
