class AddNoteToWithdrawals < ActiveRecord::Migration
  def change
    add_column :withdrawals, :note, :text
  end
end
