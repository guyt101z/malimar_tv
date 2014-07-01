class AdminsController < ApplicationController


	def create_user
		@user = User.new(params)
		password = SecureRandom.hex(7)
		@user.password = password

		if @user.save
		 	TransactionalMailer.new_user(@user, password).deliver
		 	update = AdminActivity.create(admin_id: current_admin.id, data: YAML.dump({type: 'User Registration', message: "#{current_admin.name} registered a new user.", user_id: @user.id}))
		end
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
		if @device.save
			update = AdminActivity.create(admin_id: current_admin.id, data: YAML.dump({type: 'Device Registration', message: "#{current_admin.name} registered a device.", user_id: @user.id, device_id: @device.id}))
		else

		end
	end






	def videos
		@movies = Movie.all.order(name: :desc)
		@genres = Genre.all
	end

	def add_video
		@movie = Movie.new(params)
		@movie.save
	end

	def add_image_to_video
		@movie = Movie.find(params[:movie_id])
		@movie.image = params[:image]
		@movie.save
	end



	def create_sales_rep
		@sales_rep = SalesRepresentative.new(params)
		password = SecureRandom.hex(7)
		@sales_rep.password = password

		if @sales_rep.save
			TransactionalMailer.new_rep(@sales_rep, password).deliver
			update = AdminActivity.create(admin_id: current_admin.id, data: YAML.dump({type: 'Sales Rep Registration', message: "#{current_admin.name} registered a sales representative.", rep_id: @sales_rep.id}))
		end
	end
	def sales_reps
		@reps = SalesRepresentative.all.order(first_name: :desc)
	end
	def view_rep
		@rep = SalesRepresentative.find(params[:id])
		@transactions = Transaction.where(sales_rep_id: @rep.id)
	end
	def search_reps
		all_reps = SalesRepresentative.all.order(first_name: :desc)
		@matched_reps = Array.new

		all_reps.each do |rep|
			if rep.matches?(params[:search])
				@matched_reps.push(rep)
			end
		end

		@results = @matched_reps.count
	end

	def plans
		@plans = Plan.all.order(price: :asc)
		@credentials = YAML.load(Setting.where(name: 'Paypal Credentials').first.data)
	end

	def update_paypal
		if params[:login].present? && params[:password].present? && params[:signature].present?
			@credentials = Setting.where(name: 'Paypal Credentials').first
			data = YAML.load(@credentials.data)
			data.each do |k,v|
				data[k] = params[k]
			end
			@credentials.data = YAML.dump(data)
			@credentials.save
			@message = 'Your credentials have been updated.'
			update = AdminActivity.create(admin_id: current_admin.id, data: YAML.dump({type: 'Paypal Credential Update', message: "#{current_admin.name} changed the Paypal Credentials."}))
		else
			@message = 'Please ensure all fields are filled out.'
		end
	end

	def support
		@open_cases = SupportCase.where(status: 'Open', admin_id: current_admin.id)
		@closed_cases = SupportCase.where(status: 'Closed', admin_id: current_admin.id)
	end

	def new_tickets
		@cases = SupportCase.where(status: 'Pending')
	end

	def view_device
		@device = Device.find(params[:id])
	end

	def update_device_serial
		@device = Device.find(params[:id])
		@device.serial = params[:serial]
		@device.save
	end
end
