class CreateAdminPermissions < ActiveRecord::Migration
  def change
    create_table :admin_permissions do |t|
      t.string :permission
      t.integer :level
      t.timestamps
    end
  end
end
