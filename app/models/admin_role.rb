class AdminRole < ActiveRecord::Base
    attr_accessible :name,:create_user,:manage_user,:create_rep,:manage_rep,:accept_cancel_payment,
                    :authorize_withdrawal,:update_plan_invoice,:update_videos,:update_mail_settings,
                    :manage_support_tickets

    validates_presence_of :name
    validates_uniqueness_of :name
    validates_exclusion_of :name, in: %w(Admin admin Root root Superuser superuser), message: 'is reserved'
end
