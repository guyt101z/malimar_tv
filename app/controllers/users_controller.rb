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

	def subscribe
		@one_month = Plan.find(1)
		@three_month = Plan.find(2)
		@six_month = Plan.find(3)
		@twelve_month = Plan.find(4)
	end

	def add_subscription
		@plan = Plan.find(params[:plan_id])
		@device = Device.new
		@device.type = params[:type]
		@device.serial = params[:serial]
		@device.user_id = current_user.id
		if @device.valid?
			if params[:payment_type] == 'Credit Card'
				# Put in credit transaction here
				@success = false
				@message = 'Credit card not yet active'
				@payment = false
			elsif params[:payment_type].present?
				@transaction = Transaction.new
				@transaction.user_id = current_user.id
				@transaction.status = 'Pending'
				@transaction.payment_type = params[:payment_type]
				if @plan.features.nil?
					@transaction.product_details = YAML.dump({name: @plan.name, price: @plan.price, duration: @plan.months, features: nil})
				else
					@transaction.product_details = YAML.dump({name: @plan.name, price: @plan.price, duration: @plan.months, features: YAML.load(@plan.features)})
				end
				if @transaction.save
					@success = true
					@message = 'Subscription saved. It will start when we receive your payment through ' + params[:payment_type]
					@device.save
				else
					@success = false
					@message = 'Error saving transaction'
				end
			else
				@success = false
				@message = 'Please choose a payment method'
				@payment = false
			end
		else
			@success = false
			@message = 'You need to verify your device info'
			@device_valid = false
		end
	end

	def add_note
		user = User.find(params[:user_id])
		user.note = params[:note]
		user.save
	end

	def account
		@devices = Device.where(user_id: current_user.id)
		@transactions = Transaction.where(user_id: current_user.id).order(created_at: :desc)
		@tickets = SupportCase.where(user_id: current_user.id, status: ['Pending','Open']).order(updated_at: :desc)
	end

	def new_ticket
		@transactions = Transaction.where(user_id: current_user)
		@transactions_array = [['Choose a transaction', nil]]

	end

	def view_device
		@device = Device.find(params[:id])
	end

	def update_device_serial
		@device = Device.find(params[:id])
		@device.serial = params[:serial]
		@device.save
	end

	def register_new_device
		@device = Device.new
		@device.serial = params[:serial]
		@device.user_id = current_user.id
		@device.type = 'Roku'
		@device.save
	end

	def update_profile
		@user = current_user
		@user.update_attributes(params)
		@user.save
	end
end
