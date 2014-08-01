class AddReferAFriendCodeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :refer_code, :string
    add_column :users, :balance, :float
  end
end
