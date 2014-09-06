class AddPaperlessBillingToUsers < ActiveRecord::Migration
  def change
    add_column :users, :paperless_billing, :boolean
  end
end
