class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.references :user
      t.string :serial
      t.string :type
      t.timestamps
    end
  end
end
