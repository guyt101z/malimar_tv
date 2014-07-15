class AddFrontPageToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :front_page, :boolean
  end
end
