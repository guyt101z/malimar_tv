class CreateSystemLogs < ActiveRecord::Migration
  def change
    create_table :system_logs do |t|
      t.string :message
      t.boolean :error
      t.timestamps
    end
  end
end
