class SwitchLastPrintedToDatetime < ActiveRecord::Migration
  def change
      change_column :users, :last_printed, :datetime
      change_column :devices, :last_printed, :datetime
  end
end
