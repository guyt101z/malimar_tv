class AddAddedByToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :added_by, :integer
    add_column :channels, :edited_by, :integer
  end
end
