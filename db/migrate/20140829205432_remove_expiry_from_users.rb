class RemoveExpiryFromUsers < ActiveRecord::Migration
  def change
      remove_column :users, :expiry
  end
end
