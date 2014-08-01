task :daily_update => :environment do
    today = Date.today
    data = DailyData.where(date: today).last
    if data.nil?
        data = DailyData.create(date: today)
    end

    User.update_daily_data(today)
    Transaction.update_daily_data(today)
    Withdrawal.update_daily_data(today)
end
