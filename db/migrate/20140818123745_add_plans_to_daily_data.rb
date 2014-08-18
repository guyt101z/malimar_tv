class AddPlansToDailyData < ActiveRecord::Migration
  def change
    add_column :daily_data, :plan_1, :integer
    add_column :daily_data, :plan_2, :integer
    add_column :daily_data, :plan_3, :integer
    add_column :daily_data, :plan_4, :integer
  end
end
