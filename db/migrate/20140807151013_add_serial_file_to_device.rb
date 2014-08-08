class AddSerialFileToDevice < ActiveRecord::Migration
  def change
    add_column :devices, :serial_file, :string
  end
end
