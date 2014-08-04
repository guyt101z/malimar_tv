class AddTitleToSystemLogs < ActiveRecord::Migration
  def change
    add_column :system_logs, :title, :string
  end
end
