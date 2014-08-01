class PermissionsController < ApplicationController
    def update
        if current_admin.authorized_to?('edit_permissions')
            if params[:area] == 'user'
                @create_user = AdminPermission.where(permission: 'create_user').first
                @create_user.level = params[:create_user]
                @manage_user = AdminPermission.where(permission: 'manage_user').first
                @manage_user.level = params[:manage_user]

                if @manage_user.save && @create_user.save
                    @success == true
                    @message = 'User permission settings updated.'
                else
                    @success = false
                    @message = 'User permission settings failed to update.<br>Please try again.'
                end

            elsif params[:area] == 'rep'
                @create_rep = AdminPermission.where(permission: 'create_rep').first
                @create_rep.level = params[:create_rep]
                @manage_rep = AdminPermission.where(permission: 'manage_rep').first
                @manage_rep.level = params[:manage_rep]

                if @create_rep.save && @manage_rep.save
                    @success == true
                    @message = 'Representative permission settings updated.'
                else
                    @success = false
                    @message = 'Representative permission settings failed to update.<br>Please try again.'
                end

            elsif params[:area] == 'financial'
                @accept_cancel_payment = AdminPermission.where(permission: 'accept_cancel_payment').first
                @accept_cancel_payment.level = params[:accept_cancel_payment]
                @authorize_withdrawal = AdminPermission.where(permission: 'authorize_withdrawal').first
                @authorize_withdrawal.level = params[:authorize_withdrawal]

                if @accept_cancel_payment.save && @authorize_withdrawal.save
                    @success == true
                    @message = 'Financial permission settings updated.'
                else
                    @success = false
                    @message = 'Financial permission settings failed to update.<br>Please try again.'
                end

            elsif params[:area] == 'system'
                @update_plan_invoice = AdminPermission.where(permission: 'update_plan_invoice').first
                @update_plan_invoice.level = params[:update_plan_invoice]

                @update_videos = AdminPermission.where(permission: 'update_videos').first
                @update_videos.level = params[:update_videos]

                @update_mail_settings = AdminPermission.where(permission: 'update_mail_settings').first
                @update_mail_settings.level = params[:update_mail_settings]

                @send_broadcast_mail = AdminPermission.where(permission: 'send_broadcast_mail').first
                @send_broadcast_mail.level = params[:send_broadcast_mail]


                if @update_plan_invoice.save && @update_videos.save && @update_mail_settings.save && @send_broadcast_mail.save
                    @success == true
                    @message = 'System permission settings updated.'
                else
                    @success = false
                    @message = 'System permission settings failed to update.<br>Please try again.'
                end
            end
        else
            @success = false
            @message = 'You are not the root user. Only the root user can make these changes.'
        end
    end
end
