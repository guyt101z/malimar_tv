class AddSupportToAdminRoles < ActiveRecord::Migration
  def change
    add_column :admin_roles, :manage_support_tickets, :boolean
  end
end
