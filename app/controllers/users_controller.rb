class UsersController < ApplicationController
	def create_new
		@user = User.new(params)
		if @user.save
			@success = true
			sign_in(@user)
		else
			@success = false
		end
	end
end
