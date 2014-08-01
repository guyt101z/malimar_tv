task :update_yesterday => :environment do
    yesterday = Date.yesterday
    data = DailyData.where(date: yesterday).last
    if data.nil?
        data = DailyData.create(date: yesterday)
    end

    User.update_daily_data(yesterday)
    Transaction.update_daily_data(yesterday)
    Withdrawal.update_daily_data(yesterday)

    @data = DailyData.where(date: yesterday).last

    SystemMailer.daily_report(@data).deliver
end
