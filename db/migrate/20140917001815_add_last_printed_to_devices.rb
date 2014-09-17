class AddLastPrintedToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :last_printed, :date
  end
end
