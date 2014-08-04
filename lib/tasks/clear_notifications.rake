task :clear_notifications => :environment do
    begin
        notifs = AdminNotification.where(expiry: Date.today)
        notifs.destroy_all

        SystemLog.create(error: false, title: 'Clear Notifications', message: 'Finished successfully')

        task = BackgroundTask.where(name: 'Clear Notifications').first
        task.error = false
        task.last_performed = DateTime.now
        task.save
    rescue => e
        SystemLog.create(error: true, true: 'Clear Notifications', message: e.message)

        task = BackgroundTask.where(name: 'Clear Notifications').first
        task.error = true
        task.last_performed = DateTime.now
        task.save
    end
end
