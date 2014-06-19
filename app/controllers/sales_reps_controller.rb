class SalesRepsController < ApplicationController
	def index
		@transactions = Transaction.where(sales_rep_id: current_sales_representative.id)
	end

	def register_step_one
		@user = User.new(params)
		password = SecureRandom.hex(7)
		@user.password = password
		
		if @user.save
		 	TransactionalMailer.new_user(@user, password).deliver
		 	@plans = Plan.all.order(months: :asc)
		end
	end

	def add_subscription
		@user = User.find(params[:user_id])
		@plan = Plan.find(params[:plan_id])
		@transaction = Transaction.new()

		if params[:type].present?
			unless params[:type] == 'None'
				@device = Device.new(type: params[:type], serial: params[:serial], user_id: @user.id)
				if @device.valid?
					@device_success = true
				else
					@device_success = false
					@message.nil?
				end
			else
				@device = nil
				@device_success = true
			end
		else
			@device_success = false
			@message = 'You must choose a device from the list.'
		end

		if @device_success == true
			if params[:payment_type] == 'Credit Card'
				@payment_success = false
				@message = "Credit Card Payments are not yet active."
			else
				@transaction.user_id = @user.id
				@transaction.payment_type = params[:payment_type]
				@transaction.sales_rep_id = current_sales_representative.id
				@transaction.product_details = YAML.dump({plan: @plan.name, duration: @plan.months, price: @plan.price, commission_rate: current_sales_representative.commission_rate})
				@transaction.status = 'Pending'
				@transaction.payment_status = 'Pending'

				if @transaction.valid?
					@payment_success = true
					
					unless @device.nil?
						@device.save
						@transaction.roku_id = @device.id 
					end
					if @transaction.save
						@payment_success = true
					else
						@payment_success = false
					end
				else
					@payment_success = false
				end
			end
		end
	end

	def transactions
		@transactions = Transaction.where(sales_rep_id: current_sales_representative.id)
	end

	def rep_commission
		if params[:id].present?
			rep = SalesRepresentative.find(params[:id])
			@commission = rep.total_commission
		else
			@commission = current_sales_representative.total_commission
		end
	end
	def rep_commission_owed
		if params[:id].present?
			rep = SalesRepresentative.find(params[:id])
			@commission = rep.commission_owed
		else
			@commission = current_sales_representative.commission_owed
		end
	end
	def rep_commission_paid
		if params[:id].present?
			rep = SalesRepresentative.find(params[:id])
			@commission = rep.commission_paid
		else
			@commission = current_sales_representative.commission_paid
		end
	end
end
