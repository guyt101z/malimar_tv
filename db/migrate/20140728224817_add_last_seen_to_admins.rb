class AddLastSeenToAdmins < ActiveRecord::Migration
  def change
    add_column :admins, :last_seen, :datetime
  end
end
