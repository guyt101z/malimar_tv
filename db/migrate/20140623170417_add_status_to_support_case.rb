class AddStatusToSupportCase < ActiveRecord::Migration
  def change
    add_column :support_cases, :status, :string
  end
end
