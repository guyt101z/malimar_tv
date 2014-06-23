class AddTitleToSupportCase < ActiveRecord::Migration
  def change
    add_column :support_cases, :title, :string
  end
end
