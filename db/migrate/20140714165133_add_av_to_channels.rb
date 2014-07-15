class AddAvToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :content_type, :string
  end
end
