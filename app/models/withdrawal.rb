class Withdrawal < ActiveRecord::Base
    attr_accessible :status, :amount, :sales_rep_id

    def self.update_daily_data(today)
        data = DailyData.where(date: today).last

        unless data.nil?
            withdrawal_requests_created = Withdrawal.where(created_at: today.beginning_of_day..today.end_of_day)
            withdrawal_requests_approved = Withdrawal.where(approved: today.beginning_of_day..today.end_of_day, status: 'Approved')
            withdrawal_requests_denied = Withdrawal.where(approved: today.beginning_of_day..today.end_of_day, status: 'Denied')

            data.withdrawal_requests_created = withdrawal_requests_created.count

            value = 0
            withdrawal_requests_created.each do |wd|
                value += wd.amount
            end
            data.withdrawal_requests_created_value = value


            data.withdrawal_requests_approved = withdrawal_requests_approved.count

            value = 0
            withdrawal_requests_approved.each do |wd|
                value += wd.amount
            end
            data.withdrawal_requests_approved_value = value


            data.withdrawal_requests_denied = withdrawal_requests_denied.count

            value = 0
            withdrawal_requests_denied.each do |wd|
                value += wd.amount
            end
            data.withdrawal_requests_denied_value = value

            data.wd_updated = DateTime.now
            data.save
        end
    end
end
