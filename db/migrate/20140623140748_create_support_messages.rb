class CreateSupportMessages < ActiveRecord::Migration
  def change
    create_table :support_messages do |t|
      t.references :user
      t.references :admin
      t.references :sales_representative
      t.references :support_case
      t.text :message
      t.timestamps
    end
  end
end
