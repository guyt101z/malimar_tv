class AddPremiumToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :free, :boolean
  end
end
