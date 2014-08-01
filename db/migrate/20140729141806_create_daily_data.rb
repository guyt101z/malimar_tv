class CreateDailyData < ActiveRecord::Migration
  def change
    create_table :daily_data do |t|
      t.date :date

      # User Data
      t.integer :new_sign_ups, default: 0
      t.integer :renewals, default: 0
      t.datetime :user_updated, default: 0

      # Sales Rep Data
      t.float :commission_earned, default: 0
      t.float :commission_confirmed, default: 0

      t.integer :withdrawal_requests_created, default: 0
      t.float :withdrawal_requests_created_value, default: 0
      t.integer :withdrawal_requests_approved, default: 0
      t.float :withdrawal_requests_approved_value, default: 0
      t.integer :withdrawal_requests_denied, default: 0
      t.float :withdrawal_requests_denied_value, default: 0
      t.datetime :rep_updated

      # Revenue
      t.integer :transactions_completed, default: 0
      t.float :transactions_completed_value, default: 0
      t.integer :transactions_paid, default: 0
      t.float :transactions_paid_value, default: 0
      t.datetime :tx_updated, default: 0

      t.timestamps
    end
  end
end
