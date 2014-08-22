class CreateGrids < ActiveRecord::Migration
  def change
    create_table :grids do |t|
      t.integer :grid_id
      t.string :name
      t.boolean :adult

      t.timestamps
    end
  end
end
