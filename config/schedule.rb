every 60.minutes do
    rake 'daily_update', environment: 'production'
end

every 1.day, at: '12:30 am' do
    rake 'update_yesterday', environment: 'production'
    rake 'sub_reminder', environment: 'production'
end

every 1.day, at: '12:01 am' do
    rake 'clear_duplicate_refer_codes'
    rake 'clear_notifications'
    rake 'clear_unsaved_notes'
    rake 'clear_admin_activities'
end
