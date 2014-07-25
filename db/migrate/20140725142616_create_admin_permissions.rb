class CreateAdminPermissions < ActiveRecord::Migration
  def change
    create_table :admin_permissions do |t|

      t.timestamps
    end
  end
end
