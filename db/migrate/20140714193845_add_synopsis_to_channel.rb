class AddSynopsisToChannel < ActiveRecord::Migration
  def change
    add_column :channels, :synopsis, :text
  end
end
