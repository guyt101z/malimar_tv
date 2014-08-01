class AddWdUpdatedToDailyData < ActiveRecord::Migration
  def change
    add_column :daily_data, :wd_updated, :datetime
  end
end
