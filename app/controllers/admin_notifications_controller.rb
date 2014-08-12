class AdminNotificationsController < ApplicationController
    def notification_redirect
        notif = AdminNotification.where(id: params[:id]).first

        if notif.nil?
            flash[:error] = 'Error opening notification.'
            redirect_to '/admins'
        elsif current_admin.id != notif.admin_id
            flash[:error] = 'You are not allowed to open this notification.'
            redirect_to '/admins'
        else
            notif.viewed = true
            notif.save
            redirect_to notif.link
        end
    end

    def mark_all_as_read
        notifs = AdminNotification.where(admin_id: current_admin.id)
        notifs.each do |notif|
            notif.viewed = true
            notif.save
        end
    end

    def clear
        AdminNotification.where(admin_id: current_admin.id).destroy_all
        flash[:success] = 'Notifications Cleared'
        redirect_to '/admins'
    end
end
