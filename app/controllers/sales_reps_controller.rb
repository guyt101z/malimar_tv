class SalesRepsController < ApplicationController
	def index
		@transactions = Transaction.where(sales_rep_id: current_sales_representative.id)
	end

	def update_address
		@sales_rep = current_sales_representative
		@sales_rep.address_1 = params[:address_1]
		@sales_rep.address_2 = params[:address_2]
		@sales_rep.city = params[:city]
		@sales_rep.state = params[:state]
		@sales_rep.country = params[:country]
		@sales_rep.zip = params[:zip]

		@sales_rep.save
	end

	def update_profile
		@sales_rep = current_sales_representative
		@sales_rep.first_name = params[:first_name]
		@sales_rep.last_name = params[:last_name]
		@sales_rep.email = params[:email]

		@sales_rep.save
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


	def pending_balance
		@balance = current_sales_representative.pending_balance
	end
	def current_balance
		@balance = current_sales_representative.current_balance
	end
	def pending_withdrawals
		@balance = current_sales_representative.pending_withdrawals
	end
	def total_payout
		@balance = current_sales_representative.total_payout
	end
	def meets_limit
		@status = current_sales_representative.meets_min_limit?
	end

	def view_pending_balance_details
		@start_day = Date.strptime("#{params[:start_day]}-#{params[:start_month]}-#{params[:start_year]}", '%d-%m-%Y')

		@end_day = Date.strptime("#{params[:end_day]}-#{params[:end_month]}-#{params[:end_year]}", '%d-%m-%Y')

		@detail = 'pending_balance'
		@title = 'Pending Transactions'

		if @end_day > @start_day
			@transactions = Transaction.where(sales_rep_id: current_sales_representative.id, status: 'Pending').order(created_at: :asc)
			@range_transactions = @transactions.where('created_at BETWEEN ? and ?',@start_day.beginning_of_day, @end_day.end_of_day)
			@range_balance = 0
			@range_transactions.each do |transaction|
				details = YAML.load(transaction.product_details)
				@range_balance += (details[:price] * (details[:commission_rate]/100))
			end
			@total_balance = current_sales_representative.pending_balance
			@color = '#f0ad4e'
			@status = 'Pending'
		else
			@error = true
		end
	end

	def view_current_balance_details
		@start_day = Date.strptime("#{params[:start_day]}-#{params[:start_month]}-#{params[:start_year]}", '%d-%m-%Y')

		@end_day = Date.strptime("#{params[:end_day]}-#{params[:end_month]}-#{params[:end_year]}", '%d-%m-%Y')

		@detail = 'current_balance'
		@title = 'Received Transactions'

		if @end_day > @start_day
			@transactions = Transaction.where(sales_rep_id: current_sales_representative.id, status: ['Paid', 'Refunded']).order(created_at: :asc)
			@range_transactions = @transactions.where('created_at BETWEEN ? and ?',@start_day.beginning_of_day, @end_day.end_of_day)
			@range_balance = 0
			@range_transactions.each do |transaction|
				details = YAML.load(transaction.product_details)
				@range_balance += (details[:price] * (details[:commission_rate]/100))
			end
			@total_tx = current_sales_representative.current_balance_wo_withdrawals
			@total_balance = current_sales_representative.current_balance
			@color = '#777'
			@status = 'Paid'
		else
			@error = true
		end
	end

	def view_pending_withdrawals_details
		@start_day = Date.strptime("#{params[:start_day]}-#{params[:start_month]}-#{params[:start_year]}", '%d-%m-%Y')

		@end_day = Date.strptime("#{params[:end_day]}-#{params[:end_month]}-#{params[:end_year]}", '%d-%m-%Y')

		@detail = 'pending_withdrawals'
		@title = 'Pending Withdrawals Requests'

		if @end_day > @start_day
			@withdrawals = Withdrawal.where(sales_rep_id: current_sales_representative.id, status: ['Pending','In Progress','Reviewed']).order(created_at: :asc)
			@range_withdrawals = @withdrawals.where('created_at BETWEEN ? and ?',@start_day.beginning_of_day, @end_day.end_of_day)

			@range_balance = 0

			@range_withdrawals.each do |withdrawal|
				@range_balance += withdrawal.amount
			end
			@total_balance = current_sales_representative.pending_withdrawals
			@color = '#428bca'
		else
			@error = true
		end
	end
	def view_total_payout_details
		@start_day = Date.strptime("#{params[:start_day]}-#{params[:start_month]}-#{params[:start_year]}", '%d-%m-%Y')

		@end_day = Date.strptime("#{params[:end_day]}-#{params[:end_month]}-#{params[:end_year]}", '%d-%m-%Y')

		@detail = 'total_payout'
		@title = 'Pending Withdrawals Requests'

		if @end_day > @start_day
			@withdrawals = Withdrawal.where(sales_rep_id: current_sales_representative.id, status: 'Approved').order(created_at: :asc)
			@range_withdrawals = @withdrawals.where('created_at BETWEEN ? and ?',@start_day.beginning_of_day, @end_day.end_of_day)

			@range_balance = 0

			@range_withdrawals.each do |withdrawal|
				@range_balance += withdrawal.amount
			end
			@total_balance = current_sales_representative.pending_withdrawals
			@color = '#3c763d'
		else
			@error = true
		end
	end

	def support
		@cases = SupportCase.where(sales_representative_id: current_sales_representative.id, status: ['Pending', 'Open'])
	end

	def create_ticket

	end

	def archived_tickets
		@cases = SupportCase.where(sales_representative_id: current_sales_representative.id, status: 'Closed')
	end

	def create_withdrawal
		begin
			amount = params[:amount].to_f
		rescue
			@error = 'You must enter a valid dollar value.'
		end
		if @error.nil?
			min_limit = (YAML.load(Setting.where(name: 'Withdrawal Limits').first.data))[:min]
			max_limit = (YAML.load(Setting.where(name: 'Withdrawal Limits').first.data))[:max]
			if amount > max_limit.to_f || amount < min_limit.to_f
				@error = "Must be between $#{view_context.number_with_precision(min_limit, precision: 2)} and $#{view_context.number_with_precision(max_limit, precision: 2)}."
			elsif amount > current_sales_representative.current_balance
				@error = 'You may not withdraw more than your balance.'
			else
				@withdrawal = Withdrawal.new
				@withdrawal.amount = amount
				@withdrawal.sales_rep_id = current_sales_representative.id
				@withdrawal.status = 'Pending'
				@withdrawal.save
			end
		end
	end

    def view_withdrawal_invoice
        withdrawal = Withdrawal.find(params[:id])

        if withdrawal.sales_rep_id == current_sales_representative.id
    		rep = SalesRepresentative.find(withdrawal.sales_rep_id)
			Payday::Config.default.invoice_logo = "#{Rails.root}/public#{InvoiceLogo.first.image_url(:invoice_display)}"
    		Payday::Config.default.company_name = "Malimar TV"
    		Payday::Config.default.company_details = "10 This Way\nManhattan, NY 10001\n800-111-2222\nbilling@malimar-tv.com"

    		if withdrawal.approved.blank?
    			if rep.address_2.blank? && rep.state.blank?
    				invoice = Payday::Invoice.new(invoice_number: withdrawal.id, bill_to: "#{rep.name}\n#{rep.address_1}\n#{rep.city}\n#{rep.country}\n#{rep.zip}")
    			elsif rep.state.blank?
    				invoice = Payday::Invoice.new(invoice_number: withdrawal.id, bill_to: "#{rep.name}\n#{rep.address_1}\n#{rep.address_2}\n#{rep.city}\n#{rep.country}\n#{rep.zip}")
    			elsif rep.address_2.blank?
    				invoice = Payday::Invoice.new(invoice_number: withdrawal.id, bill_to: "#{rep.name}\n#{rep.address_1}\n#{rep.city}, #{rep.state}\n#{rep.country}\n#{rep.zip}")
    			else
    				invoice = Payday::Invoice.new(invoice_number: withdrawal.id, bill_to: "#{rep.name}\n#{rep.address_1}\n#{rep.address_2}\n#{rep.city}, #{rep.state}\n#{rep.country}\n#{rep.zip}")
    			end
    		else
    			if rep.address_2.blank? && rep.state.blank?
    				invoice = Payday::Invoice.new(invoice_number: withdrawal.id, bill_to: "#{rep.name}\n#{rep.address_1}\n#{rep.city}\n#{rep.country}\n#{rep.zip}", paid_at: withdrawal.approved.strftime('%B %-d, %Y'))
    			elsif rep.state.blank?
    				invoice = Payday::Invoice.new(invoice_number: withdrawal.id, bill_to: "#{rep.name}\n#{rep.address_1}\n#{rep.address_2}\n#{rep.city}\n#{rep.country}\n#{rep.zip}", paid_at: withdrawal.approved.strftime('%B %-d, %Y'))
    			elsif rep.address_2.blank?
    				invoice = Payday::Invoice.new(invoice_number: withdrawal.id, bill_to: "#{rep.name}\n#{rep.address_1}\n#{rep.city}, #{rep.state}\n#{rep.country}\n#{rep.zip}", paid_at: withdrawal.approved.strftime('%B %-d, %Y'))
    			else
    				invoice = Payday::Invoice.new(invoice_number: withdrawal.id, bill_to: "#{rep.name}\n#{rep.address_1}\n#{rep.address_2}\n#{rep.city}, #{rep.state}\n#{rep.country}\n#{rep.zip}", paid_at: withdrawal.approved.strftime('%B %-d, %Y'))
    			end
    		end
    		invoice.line_items << Payday::LineItem.new(price: withdrawal.amount*100, description: "Commission Withdrawal", display_quantity: 1)
    		invoice.notes = withdrawal.note unless withdrawal.note.blank?



    		send_data invoice.render_pdf, filename: "Withdrawal Invoice \##{withdrawal.id} - #{withdrawal.created_at.strftime('%d/%M/%Y')}", :type => "application/pdf", :disposition => "inline"
        else
            flash[:error] = 'You are not authorized to view that.'
            redirect_to '/sales_reps' and return
        end
	end

	def view_transactions_over_period
		rep = current_sales_representative

		@start_day = Date.strptime("#{params[:start_day]}-#{params[:start_month]}-#{params[:start_year]}", '%d-%m-%Y')
		@end_day = Date.strptime("#{params[:end_day]}-#{params[:end_month]}-#{params[:end_year]}", '%d-%m-%Y')

		if rep.address_2.blank? && rep.state.blank?
			invoice = Payday::Invoice.new(invoice_number: "#{params[:status]} Transactions #{@start_day.strftime('%d/%m/%Y')} - #{@end_day.strftime('%d/%m/%Y')}", bill_to: "#{rep.name}\n#{rep.address_1}\n#{rep.city}\n#{rep.country}\n#{rep.zip}")
		elsif rep.state.blank?
			invoice = Payday::Invoice.new(invoice_number: "#{params[:status]} Transactions #{@start_day.strftime('%d/%m/%Y')} - #{@end_day.strftime('%d/%m/%Y')}", bill_to: "#{rep.name}\n#{rep.address_1}\n#{rep.address_2}\n#{rep.city}\n#{rep.country}\n#{rep.zip}")
		elsif rep.address_2.blank?
			invoice = Payday::Invoice.new(invoice_number: "#{params[:status]} Transactions #{@start_day.strftime('%d/%m/%Y')} - #{@end_day.strftime('%d/%m/%Y')}", bill_to: "#{rep.name}\n#{rep.address_1}\n#{rep.city}, #{rep.state}\n#{rep.country}\n#{rep.zip}")
		else
			invoice = Payday::Invoice.new(invoice_number: "#{params[:status]} Transactions #{@start_day.strftime('%d/%m/%Y')} - #{@end_day.strftime('%d/%m/%Y')}", bill_to: "#{rep.name}\n#{rep.address_1}\n#{rep.address_2}\n#{rep.city}, #{rep.state}\n#{rep.country}\n#{rep.zip}")
		end

		Payday::Config.default.invoice_logo = "#{Rails.root}/public#{InvoiceLogo.first.image_url(:invoice_display)}"
		Payday::Config.default.company_name = "Malimar TV"
		Payday::Config.default.company_details = "10 This Way\nManhattan, NY 10001\n800-111-2222\nbilling@malimar-tv.com"

		if params[:status] == 'Paid'
			transactions = Transaction.where(sales_rep_id: current_sales_representative.id, status: ['Paid','Refunded']).where('created_at BETWEEN ? and ?',@start_day.beginning_of_day, @end_day.end_of_day)
		else
			transactions = Transaction.where(sales_rep_id: current_sales_representative.id, status: 'Pending').where('created_at BETWEEN ? and ?',@start_day.beginning_of_day, @end_day.end_of_day)
		end

		line_items = Hash.new

		transactions.each do |tx|
			details = YAML.load(tx.product_details)
			price = ((details[:price].to_f * (details[:commission_rate]/100)) * 100).to_i
			if line_items.has_key?(price.to_s)
				line_items[price.to_s] += 1
			else
				line_items[price.to_s] = 1
			end
		end
		line_items.keys.sort

		line_items.each do |price_s, quantity|
			invoice.line_items << Payday::LineItem.new(price: price_s.to_i * quantity, display_price: "$#{view_context.number_with_precision(price_s.to_f/100, precision: 2)}", description: "Commission Item", display_quantity: quantity)
		end
		send_data invoice.render_pdf, filename: "#{params[:status]} Transactions #{@start_day.strftime('%d/%m/%Y')} - #{@end_day.strftime('%d/%m/%Y')}", :type => "application/pdf", :disposition => "inline"
	end
end
