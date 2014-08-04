class AdminNotifier
    @queue = :admin_notif

    def self.perform(admin, type, message, link)
        if admin == 0
            if type == 'system'
                admins = Admin.all

                admins.each do |admin|
                    notif = AdminNotification.new
                    notif.admin_id = admin.id
                    notif.message = message
                    notif.notif_type = 'system'
                    notif.link = link
                    notif.viewed = false
                    notif.expiry = Date.today + 30.days
                    notif.save
                end
            elsif type == 'ticket'
                admins = Admin.all

                admins.each do |admin|
                    if admin.authorized_to?('manage_support_tickets')
                        notif = AdminNotification.new
                        notif.admin_id = admin.id
                        notif.message = message
                        notif.notif_type = type
                        notif.link = link
                        notif.viewed = false
                        notif.expiry = Date.today + 30.days
                        notif.save
                    end
                end
            elsif type == 'withdrawal'
                admins = Admin.all

                admins.each do |admin|
                    if admin.authorized_to?('authorize_withdrawal')
                        notif = AdminNotification.new
                        notif.admin_id = admin.id
                        notif.message = message
                        notif.notif_type = 'system'
                        notif.link = link
                        notif.viewed = false
                        notif.expiry = Date.today + 30.days
                        notif.save
                    end
                end
            elsif type == 'root_only'
                admins = Admin.where(role_id: 0)

                admins.each do |admin|
                    notif = AdminNotification.new
                    notif.admin_id = admin.id
                    notif.message = message
                    notif.notif_type = 'system'
                    notif.link = link
                    notif.viewed = false
                    notif.expiry = Date.today + 30.days
                    notif.save
                end
            end
        else
            notif = AdminNotification.new
            notif.admin_id = admin
            notif.message = message
            notif.notif_type = type
            notif.link = link
            notif.viewed = false
            notif.expiry = Date.today + 30.days
            notif.save
        end
    end
end
