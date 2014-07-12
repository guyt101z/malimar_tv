class AddImagesToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :hd_image, :string
    add_column :channels, :sd_image, :string
  end
end
