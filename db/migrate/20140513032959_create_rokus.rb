class CreateRokus < ActiveRecord::Migration
  def change
    create_table :rokus do |t|
      t.integer :user_id
      t.string :serial
      t.timestamps
    end
  end
end
