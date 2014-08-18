task :daily_update => :environment do
    begin
        today = Date.today
        data = DailyData.where(date: today).last
        if data.nil?
            data = DailyData.create(date: today)
        end

        User.update_daily_data(today)
        Transaction.update_daily_data(today)
        Withdrawal.update_daily_data(today)
        SupportCase.update_daily_data(today)

        SystemLog.create(error: false, title: 'Daily Data Update', message: 'Finished successfully')

        task = BackgroundTask.where(name: 'Daily Data Update').first
        task.error = false
        task.last_performed = DateTime.now
        task.save

        Resque.enqueue(AdminNotifier, 0, 'daily_update', 'Today\'s data has been updated.', '/admins/background_tasks_status')
    rescue => e
        SystemLog.create(error: true, title: 'Daily Data Update', message: e.message)

        task = BackgroundTask.where(name: 'Daily Data Update').first
        task.error = true
        task.last_performed = DateTime.now
        task.save

        Resque.enqueue(AdminNotifier, 0, 'root_only', 'Error updating system data, see log.', '/admins/background_tasks_status')
    end
end
