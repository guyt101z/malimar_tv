task :sub_reminder => :environment do
    begin
        users = User.where(expiry: [15.days.from_now.to_date,7.days.from_now.to_date])

        users.each do |user|
            TransactionalMailer.subscription_reminder(user).deliver
        end

        SystemLog.create(error: false, title: 'Subscription Reminder', message: 'Finished successfully')

        task = BackgroundTask.where(name: 'Subscription Reminder').first
        task.error = false
        task.last_performed = DateTime.now
        task.save

        Resque.enqueue(AdminNotifier, 0, 'root_only', 'Subscription reminders have been sent.', '/admins/background_tasks_status')
    rescue => e
        SystemLog.create(error: true, title: 'Subscription Reminder', message: 'Finished successfully')

        task = BackgroundTask.where(name: 'Subscription Reminder').first
        task.error = true
        task.last_performed = DateTime.now
        task.save

        Resque.enqueue(AdminNotifier, 0, 'root_only', 'Error sending subscription reminders, see log.', '/admins/background_tasks_status')
    end
end
