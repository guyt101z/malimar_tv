class AddAddedByToShows < ActiveRecord::Migration
  def change
    add_column :shows, :added_by, :integer
    add_column :shows, :edited_by, :integer
  end
end
