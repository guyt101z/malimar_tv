class AddRatings < ActiveRecord::Migration
  def change
      add_column :channels, :rating, :string
      add_column :shows, :rating, :string
      add_column :movies, :rating, :string
  end
end
