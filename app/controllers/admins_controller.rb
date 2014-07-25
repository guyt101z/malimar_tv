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






	def live_channels
		@channels = Channel.all.order(name: :asc)
	end
	def shows
		@shows = Show.all.order(name: :asc)
	end
	def movies
		@movies = Movie.all.order(name: :asc)
	end
	def home_grid
		@categories = Category.all.order(rank: :asc)
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
		@invoice_details = YAML.load(Setting.where(name: 'Invoice Details').first.data)
		@logo = InvoiceLogo.first
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

	def payments
		@withdrawals = Withdrawal.where(status: 'Approved')
	end

	def payment_requests
		@withdrawals = Withdrawal.where(status: ['Pending','In Progress', 'Reviewed'])
	end

	def view_request
		@withdrawal = Withdrawal.find(params[:id])
		@withdrawal.status = 'Reviewed'
		@withdrawal.save
		@rep = SalesRepresentative.find(@withdrawal.sales_rep_id)
	end

	def approve_request
		@withdrawal = Withdrawal.find(params[:id])
		@withdrawal.status = 'Approved'
		@withdrawal.approved = DateTime.now
		@withdrawal.admin_id = current_admin.id
		@withdrawal.note = params[:note]
		@withdrawal.save
	end

	def deny_request
		@withdrawal = Withdrawal.find(params[:id])
		@withdrawal.status = 'Denied'
		@withdrawal.approved = DateTime.now
		@withdrawal.admin_id = current_admin.id
		@withdrawal.note = params[:note]
		@withdrawal.save
	end






	def update_rep_profile
		@rep = SalesRepresentative.find(params[:id])
		@rep.first_name = params[:first_name]
		@rep.last_name = params[:last_name]
		@rep.email = params[:email]
		@rep.save
	end

	def update_rep_mailing
		@rep = SalesRepresentative.find(params[:id])
		@rep.address_1 = params[:address_1]
		@rep.address_2 = params[:address_2]
		@rep.city = params[:city]
		@rep.state = params[:state]
		@rep.country = params[:country]
		@rep.zip = params[:zip]

		@rep.save
	end

	def update_rep_commission
		@rep = SalesRepresentative.find(params[:id])
		@rep.commission_rate = params[:new_rate]

		@rep.save
	end


	def rep_pending_balance
		@balance = SalesRepresentative.find(params[:rep_id]).pending_balance
	end
	def rep_current_balance
		@balance = SalesRepresentative.find(params[:rep_id]).current_balance
	end
	def rep_pending_withdrawals
		@balance = SalesRepresentative.find(params[:rep_id]).pending_withdrawals
	end
	def rep_total_payout
		@balance = SalesRepresentative.find(params[:rep_id]).total_payout
	end


	def view_pending_balance_details
		@rep = SalesRepresentative.find(params[:id])
		@start_day = Date.strptime("#{params[:start_day]}-#{params[:start_month]}-#{params[:start_year]}", '%d-%m-%Y')

		@end_day = Date.strptime("#{params[:end_day]}-#{params[:end_month]}-#{params[:end_year]}", '%d-%m-%Y')

		@detail = 'pending_balance'
		@title = 'Pending Transactions'

		if @end_day > @start_day
			@transactions = Transaction.where(sales_rep_id: @rep.id, status: 'Pending').order(created_at: :asc)
			@range_transactions = @transactions.where('created_at BETWEEN ? and ?',@start_day.beginning_of_day, @end_day.end_of_day)
			@range_balance = 0
			@range_transactions.each do |transaction|
				details = YAML.load(transaction.product_details)
				@range_balance += (details[:price] * (details[:commission_rate]/100))
			end
			@total_balance = @rep.pending_balance
			@color = '#f0ad4e'
			@status = 'Pending'
		else
			@error = true
		end
	end

	def view_current_balance_details
		@rep = SalesRepresentative.find(params[:id])
		@start_day = Date.strptime("#{params[:start_day]}-#{params[:start_month]}-#{params[:start_year]}", '%d-%m-%Y')

		@end_day = Date.strptime("#{params[:end_day]}-#{params[:end_month]}-#{params[:end_year]}", '%d-%m-%Y')

		@detail = 'current_balance'
		@title = 'Received Transactions'

		if @end_day > @start_day
			@transactions = Transaction.where(sales_rep_id: @rep.id, status: ['Paid', 'Refunded']).order(created_at: :asc)
			@range_transactions = @transactions.where('created_at BETWEEN ? and ?',@start_day.beginning_of_day, @end_day.end_of_day)
			@range_balance = 0
			@range_transactions.each do |transaction|
				details = YAML.load(transaction.product_details)
				@range_balance += (details[:price] * (details[:commission_rate]/100))
			end
			@total_tx = @rep.current_balance_wo_withdrawals
			@total_balance = @rep.current_balance
			@color = '#777'
			@status = 'Paid'
		else
			@error = true
		end
	end

	def view_pending_withdrawals_details
		@rep = SalesRepresentative.find(params[:id])
		@start_day = Date.strptime("#{params[:start_day]}-#{params[:start_month]}-#{params[:start_year]}", '%d-%m-%Y')

		@end_day = Date.strptime("#{params[:end_day]}-#{params[:end_month]}-#{params[:end_year]}", '%d-%m-%Y')

		@detail = 'pending_withdrawals'
		@title = 'Pending Withdrawals Requests'

		if @end_day > @start_day
			@withdrawals = Withdrawal.where(sales_rep_id: @rep.id, status: ['Pending','In Progress','Reviewed']).order(created_at: :asc)
			@range_withdrawals = @withdrawals.where('created_at BETWEEN ? and ?',@start_day.beginning_of_day, @end_day.end_of_day)

			@range_balance = 0

			@range_withdrawals.each do |withdrawal|
				@range_balance += withdrawal.amount
			end
			@total_balance = @rep.pending_withdrawals
			@color = '#428bca'
		else
			@error = true
		end
	end
	def view_total_payout_details
		@rep = SalesRepresentative.find(params[:id])
		@start_day = Date.strptime("#{params[:start_day]}-#{params[:start_month]}-#{params[:start_year]}", '%d-%m-%Y')

		@end_day = Date.strptime("#{params[:end_day]}-#{params[:end_month]}-#{params[:end_year]}", '%d-%m-%Y')

		@detail = 'total_payout'
		@title = 'Pending Withdrawals Requests'

		if @end_day > @start_day
			@withdrawals = Withdrawal.where(sales_rep_id: @rep.id, status: 'Approved').order(created_at: :asc)
			@range_withdrawals = @withdrawals.where('created_at BETWEEN ? and ?',@start_day.beginning_of_day, @end_day.end_of_day)

			@range_balance = 0

			@range_withdrawals.each do |withdrawal|
				@range_balance += withdrawal.amount
			end
			@total_balance = @rep.pending_withdrawals
			@color = '#3c763d'
		else
			@error = true
		end
	end


	def view_withdrawal_invoice
		withdrawal = Withdrawal.find(params[:id])
		rep = SalesRepresentative.find(withdrawal.sales_rep_id)
		invoice_details = YAML.load(Setting.where(name: 'Invoice Details').first.data)
		Payday::Config.default.invoice_logo = "#{Rails.root}/public#{InvoiceLogo.first.image_url(:invoice_display)}"
		Payday::Config.default.company_name = "#{invoice_details[:company_name]}"
		Payday::Config.default.company_details = "#{invoice_details[:address]}"

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
	end

	def view_transactions_over_period
		rep = SalesRepresentative.find(params[:id])

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

		invoice_details = YAML.load(Setting.where(name: 'Invoice Details').first.data)
		Payday::Config.default.invoice_logo = "#{Rails.root}/public#{InvoiceLogo.first.image_url(:invoice_display)}"
		Payday::Config.default.company_name = "#{invoice_details[:company_name]}"
		Payday::Config.default.company_details = "#{invoice_details[:address]}"

		if params[:status] == 'Paid'
			transactions = Transaction.where(sales_rep_id: rep.id, status: ['Paid','Refunded']).where('created_at BETWEEN ? and ?',@start_day.beginning_of_day, @end_day.end_of_day)
		else
			transactions = Transaction.where(sales_rep_id: rep.id, status: 'Pending').where('created_at BETWEEN ? and ?',@start_day.beginning_of_day, @end_day.end_of_day)
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

	def update_invoice_details
		@invoice_details = Setting.where(name: 'Invoice Details').first
		data = YAML.load(@invoice_details.data)


		if params[:address].present? && params[:company_name].present?
			data[:address] = params[:address]
			data[:company_name] = params[:company_name]

			@invoice_details.data = YAML.dump(data)
			@invoice_details.save
			@success = true
		else
			@success = false
		end
	end

	def upload_invoice_logo
		@logo = InvoiceLogo.first
		@logo.image = params[:image]

		if @logo.save
			@success = true
		else
			render status: 500
		end
	end

	def user_payment_queue
		@transactions = Transaction.where(status: 'Pending')
	end
end
