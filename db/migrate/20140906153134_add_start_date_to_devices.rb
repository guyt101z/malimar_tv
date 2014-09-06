class AddStartDateToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :start_date, :date
  end
end
