class CreateAdminActivities < ActiveRecord::Migration
  def change
    create_table :admin_activities do |t|
      t.integer :admin_id
      t.text :data
      t.timestamps
    end
  end
end
