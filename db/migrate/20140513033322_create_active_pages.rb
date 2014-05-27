class CreateActivePages < ActiveRecord::Migration
  def change
    create_table :active_pages do |t|
      t.string :action
      t.string :controller
      t.text :content
      t.timestamps
    end
  end
end
