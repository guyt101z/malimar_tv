class AddRepIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :rep_id, :integer
  end
end
