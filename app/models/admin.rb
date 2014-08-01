class Admin < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  	attr_accessible :email, :password, :password_confirmation, :first_name, :last_name, :role_id

      validates_presence_of :first_name, :last_name

  	def name
  		return "#{first_name} #{last_name}"
  	end

    def is_root?
        if rank == 0
            return true
        else
            return false
        end
    end

    def authorized_to?(action)
        if role_id > 0
            unless action == 'edit_permissions' || action == 'edit_general_settings'
                role = AdminRole.find(role_id)

                if action == 'create_user'
                    if role.create_user == true
                        true
                    else
                        false
                    end
                elsif action == 'manage_user'
                    if role.manage_user == true
                        true
                    else
                        false
                    end
                elsif action == 'create_rep'
                    if role.create_rep == true
                        true
                    else
                        false
                    end
                elsif action == 'manage_rep'
                    if role.manage_rep == true
                        true
                    else
                        false
                    end
                elsif action == 'create_admin'
                    if role.create_admin == true
                        true
                    else
                        false
                    end
                elsif action == 'manage_admin'
                    if role.manage_admin == true
                        true
                    else
                        false
                    end
                elsif action == 'accept_cancel_payments'
                    if role.accept_cancel_payments == true
                        true
                    else
                        false
                    end
                elsif action == 'authorize_withdrawal'
                    if role.authorize_withdrawal == true
                        true
                    else
                        false
                    end
                elsif action == 'update_plan_invoice'
                    if role.update_plan_invoice == true
                        true
                    else
                        false
                    end
                elsif action == 'update_videos'
                    if role.update_videos == true
                        true
                    else
                        false
                    end
                elsif action == 'update_mail_settings'
                    if role.update_mail_settings == true
                        true
                    else
                        false
                    end
                elsif action == 'manage_support_tickets'
                    if role.manage_support_tickets == true
                        true
                    else
                        false
                    end
                end
            else
                return role_id == 0
            end
        elsif role_id == 0
            return true
        elsif role_id.nil?
            return false
        end
    end

    def role
        if role_id == 0
            return 'Root'
        elsif role_id.nil?
            return 'None'
        else
            return AdminRole.find(role_id).name
        end
    end

    def missed_system_notifications
        if role_id == 0
            return AdminNotification.where(admin_id: id, notif_type: ['system','root_only'], viewed: false).count
        else
            return AdminNotification.where(admin_id: id, notif_type: 'system', viewed: false).count
        end
    end

    def system_notifications
        if role_id == 0
            return AdminNotification.where(admin_id: id, notif_type: ['system','root_only'])
        else
            return AdminNotification.where(admin_id: id, notif_type: 'system')
        end
    end

    def missed_ticket_notifications
        return AdminNotification.where(admin_id: id, viewed: false, notif_type: 'ticket').count
    end

    def ticket_notifications
        return AdminNotification.where(admin_id: id, notif_type: 'ticket')
    end
end
