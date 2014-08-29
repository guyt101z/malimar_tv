class RemoveExpiryFromUsers < ActiveRecord::Migration
  def change
      remove_column :users, :expiry
      remove_column :devices, :expiry
  end
end
