class AdminsController < ApplicationController
	def create_user
		@user = User.new(params)
		@user.password = SecureRandom.hex(7)
		@user.save
	end
	
	def users
		@users = User.all.order(first_name: :desc)
	end
	
	def search_users
		all_users = User.all.order(first_name: :desc)
		@matched_users = Array.new
		
		all_users.each do |user|
			if user.matches?(params[:search])
				@matched_users.push(user)
			end
		end
		
		if @matched_users.any?
			@results = @matched_users.count
		else
			@results = 0
			
		end
	end
	
	def view_user
		@user = User.find(params[:id])
		@devices = Device.where(user_id: @user.id)
		@transactions = Transaction.where(user_id: @user.id)
	end
	
	def register_device
		@user = User.find(params[:user_id])
		@device = Device.new(user_id: @user.id, serial: params[:serial], type: params[:type])
		@device.save
	end
end
