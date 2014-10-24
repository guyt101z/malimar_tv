class AddWeightToGridItems < ActiveRecord::Migration
  def change
    add_column :grid_items, :weight, :integer
  end
end
