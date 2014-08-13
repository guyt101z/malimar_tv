class CreateAdultContent < ActiveRecord::Migration
  def change
    add_column :users, :adult, :boolean
    add_column :movies, :adult, :boolean
    add_column :channels, :adult, :boolean
    add_column :shows, :adult, :boolean
  end
end
