task :clear_unsaved_notes => :environment do
    begin
        notes = UserNote.where(user_id: nil)

        notes.each do |note|
            files = NoteFile.where(note_id: note.id)
            files.destroy_all
        end

        notes.destroy_all

        SystemLog.create(error: false, title: 'Clear Unsaved Notes', message: 'Finished successfully')

        task = BackgroundTask.where(name: 'Clear Unsaved Notes').first
        task.error = false
        task.last_performed = DateTime.now
        task.save

        Resque.enqueue(AdminNotifier, 0, 'root_only', 'Unsaved User Notes have been cleared.' '/admins/background_tasks_status')
    rescue => e
        SystemLog.create(error: true, title: 'Clear Notifications', message: 'Finished successfully')

        task = BackgroundTask.where(name: 'Clear Notifications').first
        task.error = true
        task.last_performed = DateTime.now
        task.save

        Resque.enqueue(AdminNotifier, 0, 'root_only', 'Error clearing unsaved user notes, see log.' '/admins/background_tasks_status')
    end
end
