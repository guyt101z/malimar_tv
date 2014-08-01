class AddRankToAdmins < ActiveRecord::Migration
  def change
    add_column :admins, :rank, :integer
  end
end
