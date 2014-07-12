class AddImageToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :image, :string
    remove_column :channels, :hd_image
    remove_column :channels, :sd_image
  end
end
