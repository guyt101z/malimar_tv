class CreateUserNotes < ActiveRecord::Migration
  def change
    create_table :user_notes do |t|
      t.integer :user_id
      t.string :title
      t.text :note
      t.string :note_colour
      t.text :checklist, limit: 4294967295
      t.timestamps
    end
  end
end
