class PrepBanners < ActiveRecord::Migration
  def change
      add_column :movies, :front_page, :boolean
      add_column :movies, :banner, :string

      add_column :shows, :front_page, :boolean
      add_column :shows, :banner, :string

      add_column :channels, :front_page, :boolean
      add_column :channels, :banner, :string
  end
end
