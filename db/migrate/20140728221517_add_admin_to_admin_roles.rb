class AddAdminToAdminRoles < ActiveRecord::Migration
  def change
    add_column :admin_roles, :create_admin, :boolean
    add_column :admin_roles, :manage_admin, :boolean
  end
end
