class AddSortToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :sort, :string
  end
end
