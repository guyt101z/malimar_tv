class AddMailchimpToUsers < ActiveRecord::Migration
  def change
    add_column :users, :mailchimp, :boolean
  end
end
