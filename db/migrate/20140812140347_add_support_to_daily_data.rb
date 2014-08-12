class AddSupportToDailyData < ActiveRecord::Migration
  def change
    add_column :daily_data, :opened_tickets, :integer
    add_column :daily_data, :closed_tickets, :integer
    add_column :daily_data, :archived_tickets, :integer
  end
end
