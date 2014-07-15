class PrepareCategories < ActiveRecord::Migration
  def change
      add_column :categories, :genre, :string
      add_column :categories, :content_type, :string
      add_column :categories, :content_quality, :string
      add_column :categories, :item_type, :string

      add_column :movies, :content_quality, :string

      add_column :channels, :content_quality, :string
  end
end
