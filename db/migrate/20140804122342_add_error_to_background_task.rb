class AddErrorToBackgroundTask < ActiveRecord::Migration
  def change
    add_column :background_tasks, :error, :boolean
  end
end
