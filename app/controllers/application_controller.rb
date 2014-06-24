class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  	protect_from_forgery
  	
  	before_filter :update_last_seen
  

  	def update_last_seen
  		if user_signed_in?
  			@user = current_user
  			@user.last_seen = DateTime.now
  			@user.save
		  end
  	end

    def timezone
      Time.zone = 'UTC'
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


    helper_method :custom_time_ago
    def custom_time_ago(time_str)

      time = time_str.to_time

      "#{view_context.distance_of_time_in_words_to_now(time)} ago"

    end
end
