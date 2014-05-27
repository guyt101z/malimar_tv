class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.float :price
      t.integer :days
      t.string :name
      t.timestamps
    end
  end
end
