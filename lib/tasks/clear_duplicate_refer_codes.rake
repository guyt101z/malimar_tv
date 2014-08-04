task :clear_duplicate_refer_codes => :environment do
    begin
        users = User.all

        users.each do |user|
            other_users = User.where(refer_code: user.refer_code)

            if other_users.count > 1
                user.refer_code = SecureRandom.hex(5)
                until user.valid?
                    user.refer_code = SecureRandom.hex(5)
                end
                user.save
            end
        end

        SystemLog.create(error: false, title: 'Clear Duplicate Refer Codes', message: 'Finished successfully')

        task = BackgroundTask.where(name: 'Clear Duplicate Refer Codes').first
        task.error = false
        task.last_performed = DateTime.now
        task.save

        Resque.enqueue(AdminNotifier, 0, 'root_only', 'Duplicate referrals have been updated.', '/admins/background_tasks_status')
    rescue => e
        SystemLog.create(error: true, title: 'Clearing Admin Activities', message: e.message)

        task = BackgroundTask.where(name: 'Clear Duplicate Refer Codes').first
        task.error = true
        task.last_performed = DateTime.now
        task.save

        Resque.enqueue(AdminNotifier, 0, 'root_only', 'Error clearing duplicate refer codes, see log','/admins/background_tasks_status')
    end
end
