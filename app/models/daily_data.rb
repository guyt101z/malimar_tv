class DailyData < ActiveRecord::Base
    attr_accessible :date, :new_sign_ups, :renewals, :user_updated, :commission_earned, :commission_confirmed, :withdrawal_requests_created,
                    :withdrawal_requests_created_value, :withdrawal_requests_approved, :withdrawal_requests_approved_value,
                    :withdrawal_requests_denied, :withdrawal_requests_denied_value, :rep_updated, :transactions_completed,
                    :transactions_completed_value, :transactions_paid, :transactions_paid_value, :tx_updated,
                    :opened_tickets, :closed_tickets, :archived_tickets, :new_tickets

    validates_presence_of :date
end
