class AddRankToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :rank, :integer
  end
end
