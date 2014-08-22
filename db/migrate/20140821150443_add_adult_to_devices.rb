class AddAdultToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :adult, :boolean
  end
end
