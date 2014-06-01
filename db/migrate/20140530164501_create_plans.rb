class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.string :name
      t.text :features
      t.integer :price
      t.integer :months
      t.timestamps
    end
  end
end
