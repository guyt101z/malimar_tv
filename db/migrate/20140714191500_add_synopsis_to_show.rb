class AddSynopsisToShow < ActiveRecord::Migration
  def change
    add_column :shows, :synopsis, :text
  end
end
