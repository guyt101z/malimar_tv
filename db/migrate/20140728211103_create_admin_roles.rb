class CreateAdminRoles < ActiveRecord::Migration
  def change
    create_table :admin_roles do |t|
      t.string :name

      t.boolean :create_user
      t.boolean :manage_user

      t.boolean :create_rep
      t.boolean :manage_rep

      t.boolean :accept_cancel_payment
      t.boolean :authorize_withdrawal

      t.boolean :update_plan_invoice

      t.boolean :update_videos

      t.boolean :update_mail_settings

      t.timestamps
    end

    add_column :admins, :role_id, :integer #0 is root
    remove_column :admins, :rank
  end
end
