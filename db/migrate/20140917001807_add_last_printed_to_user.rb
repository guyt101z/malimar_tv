class AddLastPrintedToUser < ActiveRecord::Migration
  def change
    add_column :users, :last_printed, :date
  end
end
