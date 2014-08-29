class AddSlugToShows < ActiveRecord::Migration
  def change
    add_column :shows, :slug, :string
  end
end
