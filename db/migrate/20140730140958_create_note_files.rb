class CreateNoteFiles < ActiveRecord::Migration
  def change
    create_table :note_files do |t|
      t.integer :note_id
      t.string :file
      t.timestamps
    end
  end
end
