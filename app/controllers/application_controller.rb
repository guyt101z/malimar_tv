class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  	protect_from_forgery

  	before_filter :update_last_seen, :timezone


  	def update_last_seen
  		if user_signed_in?
  			@user = current_user
  			@user.last_seen = DateTime.now
  			@user.save
		end
        if admin_signed_in?
            @admin = current_admin
            @admin.last_seen = DateTime.now
            @admin.save
        end
  	end

    helper_method :timezone
    def timezone
        if admin_signed_in? && current_admin.timezone.blank? == false
            Time.zone = current_admin.timezone
        elsif sales_representative_signed_in? && current_sales_representative.timezone.blank? == false
            Time.zone = current_sales_representative.timezone
        elsif user_signed_in? && current_user.timezone.blank? == false
            Time.zone = current_user.timezone
        else
            Time.zone = Setting.where(name: 'Default Timezone').first.data
        end
    end

    def after_sign_in_path_for(resource)
      if resource.is_a? Admin
        admins_path
      elsif resource.is_a? SalesRepresentative
        sales_reps_path
      else
        root_path
      end
    end

    helper_method :notif_icons
    def notif_icons
        return {error: 'exclamation-circle', success: 'check-circle', alert: 'info-circle', notice: 'info-circle'}
    end

    helper_method :custom_time_ago
    def custom_time_ago(time_str)

      time = time_str.to_time

      "#{view_context.distance_of_time_in_words_to_now(time)} ago"

    end
end
