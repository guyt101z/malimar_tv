class CreateSupportCases < ActiveRecord::Migration
  def change
    create_table :support_cases do |t|
      t.references :admin
      t.references :user
      t.references :sales_representative
      t.text :issue_description
      t.integer :priority
      t.string :category
      t.timestamps
    end
  end
end
