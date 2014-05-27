class CreateSerials < ActiveRecord::Migration
  def change
    create_table :serials do |t|
      t.integer :roku_id
      t.string :file
      t.timestamps
    end
  end
end
