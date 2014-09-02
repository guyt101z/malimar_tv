class AddExpiryToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :expiry, :date
  end
end
