class AddIsActiveToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :is_active, :boolean, default: true
  end
end
