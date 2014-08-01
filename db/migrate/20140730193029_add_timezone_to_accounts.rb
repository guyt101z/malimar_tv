class AddTimezoneToAccounts < ActiveRecord::Migration
  def change
      add_column :admins, :timezone, :string
      add_column :sales_representatives, :timezone, :string
      add_column :users, :timezone, :string
  end
end
