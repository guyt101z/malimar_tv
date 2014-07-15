class AddMembershipToShows < ActiveRecord::Migration
  def change
    add_column :shows, :free, :boolean
  end
end
