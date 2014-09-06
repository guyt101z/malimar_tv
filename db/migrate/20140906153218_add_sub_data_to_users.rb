class AddSubDataToUsers < ActiveRecord::Migration
  def change
    add_column :users, :start_date, :date
    add_column :users, :expiry, :date
  end
end
