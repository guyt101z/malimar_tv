class AddBooleansToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :live, :boolean
    add_column :channels, :free, :boolean
  end
end
