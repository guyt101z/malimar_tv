task :clear_admin_activities => :environment do
    begin
        activities = AdminActivity.where("created_at < ?", Date.today - 30.days)
        activities.destroy_all

        SystemLog.create(error: false, title: 'Clearing Admin Activities', message: 'Finished successfully')

        task = BackgroundTask.where(name: 'Clear Admin Activities').first
        task.error = false
        task.last_performed = DateTime.now
        task.save

        Resque.enqueue(AdminNotifier, 0, 'root_only', 'Old activities have been cleared','/admins/background_tasks_status')
    rescue => e
        SystemLog.create(error: true, title: 'Clearing Admin Activities', message: e.message)

        task = BackgroundTask.where(name: 'Clear Admin Activities').first
        task.error = true
        task.last_performed = DateTime.now
        task.save

        Resque.enqueue(AdminNotifier, 0, 'root_only', 'Error clearing old activities, see log','/admins/background_tasks_status')
    end
end
