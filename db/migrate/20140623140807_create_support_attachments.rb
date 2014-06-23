class CreateSupportAttachments < ActiveRecord::Migration
  def change
    create_table :support_attachments do |t|
      t.references :support_case
      t.string :file
      t.timestamps
    end
  end
end
