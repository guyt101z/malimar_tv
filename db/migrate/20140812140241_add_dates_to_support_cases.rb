class AddDatesToSupportCases < ActiveRecord::Migration
  def change
    add_column :support_cases, :opened, :date
    add_column :support_cases, :closed, :date
    add_column :support_cases, :archived, :date
  end
end
