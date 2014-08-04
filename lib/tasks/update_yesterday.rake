task :update_yesterday => :environment do
    begin
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

        SystemLog.create(error: false, title: 'Previous Day\'s Data Update', message: 'Finished successfully')

        task = BackgroundTask.where(name: 'Previous Day\'s Data Update').first
        task.error = false
        task.last_performed = DateTime.now
        task.save

        Resque.enqueue(AdminNotifier, 0, 'root_only', 'Yesterday\'s data has been updated.', '/admins/background_tasks_status')
    rescue => e
        SystemLog.create(error: true, title: 'Previous Day\'s Data Update', message: 'Finished successfully')

        task = BackgroundTask.where(name: 'Previous Day\'s Data Update').first
        task.error = true
        task.last_performed = DateTime.now
        task.save

        Resque.enqueue(AdminNotifier, 0, 'root_only', 'Error updating yesterday\'s data, see log.', '/admins/background_tasks_status')
    end
end
