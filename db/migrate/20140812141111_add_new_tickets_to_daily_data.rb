class AddNewTicketsToDailyData < ActiveRecord::Migration
  def change
    add_column :daily_data, :new_tickets, :integer
  end
end
