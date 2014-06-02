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
end
