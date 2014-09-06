class AddRokuDataToUser < ActiveRecord::Migration
  def change
    add_column :users, :roku_email, :string
    add_column :users, :roku_password, :string
  end
end
