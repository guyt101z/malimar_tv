class AddHighPriorityToSupportCases < ActiveRecord::Migration
  def change
    add_column :support_cases, :high_priority, :boolean
  end
end
