class AddPhonesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :phone_1, :string
    add_column :users, :phone_2, :string
    add_column :users, :phone_3, :string
  end
end
