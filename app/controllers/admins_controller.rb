class AdminsController < ApplicationController
	def index
		@data = DailyData.where(date: Date.today).last
	end
	def new_user
		unless current_admin.authorized_to?('create_user')
			flash[:error] = 'You are not authorized to view that.'
			redirect_to '/admins'
		end
	end

	def create_user
		if current_admin.authorized_to?('create_user')
			@user = User.new(params)
			password = SecureRandom.hex(7)
			code = SecureRandom.hex(5).upcase
			until User.where(refer_code: code).count < 1
				code = SecureRandom.hex(5).upcase
			end
			@user.refer_code = code
			@user.balance = 0
			@user.password = password

			if @user.save
				TransactionalMailer.admin_register_customer(@user, password).deliver
				update = AdminActivity.create(admin_id: current_admin.id, data: YAML.dump({type: 'User Registration', message: "#{current_admin.name} registered a new user.", user_id: @user.id}))
				Resque.enqueue(AdminNotifier, 0, 'system', "#{@user.name} has joined.", search_users_path(id: @user.id))
			end
		else
			render status: 403
		end
	end

	def users
		if current_admin.authorized_to?('manage_user')
			@users = User.all.order(first_name: :desc)
		else
			flash[:error] = 'You do not have permission to view that.'
			redirect_to '/admins'
		end
	end

	def search_users
		if current_admin.authorized?('manage_user')
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
		else
			render status: 403
		end
	end

	def view_user
		if current_admin.authorized_to?('manage_user')
			@user = User.find(params[:id])
			@devices = Device.where(user_id: @user.id)
			@transactions = Transaction.where(user_id: @user.id)
			@notes = UserNote.where(user_id: @user.id)
		else
			flash[:error] = 'You do not have permission to view that.'
			redirect_to '/admins'
		end
	end

	def register_device
		if current_admin.authorized_to?('manage_user')
			@user = User.find(params[:user_id])
			@device = Device.new(user_id: @user.id, serial: params[:serial], type: params[:type])
			if @device.save
				update = AdminActivity.create(admin_id: current_admin.id, data: YAML.dump({type: 'Device Registration', message: "#{current_admin.name} registered a device.", user_id: @user.id, device_id: @device.id}))
			end
		end
	end

	def sys_log
		@logs = SystemLog.all.reverse
	end




	def live_channels
		if current_admin.authorized_to?('update_videos')
			@channels = Channel.all.order(name: :asc)
		else
			flash[:error] = 'You are not authorized to view that'
		end
	end
	def shows
		if current_admin.authorized_to?('update_videos')
			@shows = Show.all.order(name: :asc)
		else
			flash[:error] = 'You are not authorized to view that'
		end
	end
	def movies
		if current_admin.authorized_to?('update_videos')
			@movies = Movie.all.order(name: :asc)
		else
			flash[:error] = 'You are not authorized to view that'
		end
	end
	def home_grid
		if current_admin.authorized_to?('update_videos')
			@categories = Category.all.order(rank: :asc)
		else
			flash[:error] = 'You are not authorized to view that'
		end
	end

	def new_sales_rep
		unless current_admin.authorized_to?('create_rep')
			flash[:error] = 'You are not authorized to view that.'
			redirect_to '/admins'
		end
	end

	def create_sales_rep
		if current_admin.authorized_to?('create_rep')
			@sales_rep = SalesRepresentative.new(params)
			password = SecureRandom.hex(7)
			@sales_rep.password = password

			if @sales_rep.save
				TransactionalMailer.admin_register_sales_representative(@sales_rep, password).deliver
				update = AdminActivity.create(admin_id: current_admin.id, data: YAML.dump({type: 'Sales Rep Registration', message: "#{current_admin.name} registered a sales representative.", rep_id: @sales_rep.id}))
				Resque.enqueue(AdminNotifier, 0, 'system', "#{@sales_rep.name} has joined as a Sales Representative.", view_rep_path(id: @sales_rep.id))
			end
		else
			render status: 403
		end
	end
	def sales_reps
		if current_admin.authorized_to?('manage_rep')
			@reps = SalesRepresentative.all.order(first_name: :desc)
		else
			flash[:error] = 'You are not authorized to view that.'
			redirect_to '/admins'
		end
	end
	def view_rep
		if current_admin.authorized_to?('manage_rep')
			@rep = SalesRepresentative.find(params[:id])
			@transactions = Transaction.where(sales_rep_id: @rep.id)
		else
			flash[:error] = 'You are not authorized to view that.'
			redirect_to '/admins'
		end
	end
	def search_reps
		if current_admin.authorized_to?('manage_rep')
			all_reps = SalesRepresentative.all.order(first_name: :desc)
			@matched_reps = Array.new

			all_reps.each do |rep|
				if rep.matches?(params[:search])
					@matched_reps.push(rep)
				end
			end

			@results = @matched_reps.count
		else
			render status: 403
		end
	end

	def plans
		if current_admin.authorized_to?('update_plan_invoice')
			@plans = Plan.all.order(price: :asc)
			@credentials = YAML.load(Setting.where(name: 'Paypal Credentials').first.data)
			@invoice_details = YAML.load(Setting.where(name: 'Invoice Details').first.data)
			@logo = InvoiceLogo.first
		else
			flash[:error] = 'You are not authorized to view that.'
			redirect_to '/admins'
		end
	end

	def update_paypal
		if current_admin.authorized_to?('update_plan_invoice')
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
				@success = true
			else
				@message = 'Please ensure all fields are filled out.'
				@success = false
			end
		else
			render status: 403
		end
	end

	def support
		if current_admin.authorized_to?('manage_support_tickets')
			@open_cases = SupportCase.where(status: 'Open', admin_id: current_admin.id)
			@closed_cases = SupportCase.where(status: 'Closed', admin_id: current_admin.id)
		else
			flash[:error] = 'You are not allowed to view that.'
			redirect_to '/admins' and return
		end
	end

	def new_tickets
		@cases = SupportCase.where(status: 'Pending')
	end

	def view_device
		if current_admin.authorized_to?('manage_user')
			@device = Device.find(params[:id])
		else
			render status: 403
		end
	end

	def update_device_serial
		if current_admin.authorized_to?('manage_user')
			@device = Device.find(params[:id])
			@device.serial = params[:serial]
			@device.save
		else
			render status: 403
		end
	end

	def payments
		if current_admin.authorized_to?('authorize_withdrawal')
			@withdrawals = Withdrawal.where(status: 'Approved')
		else
			flash[:error] = 'You are not authorized to view that.'
			redirect_to '/admins'
		end
	end

	def payment_requests
		if current_admin.authorized_to?('authorize_withdrawal')
			@withdrawals = Withdrawal.where(status: ['Pending','In Progress', 'Reviewed'])
		else
			flash[:error] = 'You are not authorized to view that.'
			redirect_to '/admins'
		end
	end

	def view_request
		if current_admin.authorized_to?('authorize_withdrawal')
			@withdrawal = Withdrawal.find(params[:id])
			@withdrawal.status = 'Reviewed'
			@withdrawal.save
			@rep = SalesRepresentative.find(@withdrawal.sales_rep_id)
		else
			render status: 403
		end
	end

	def approve_request
		if current_admin.authorized_to?('authorize_withdrawal')
			@withdrawal = Withdrawal.find(params[:id])
			@withdrawal.status = 'Approved'
			@withdrawal.approved = DateTime.now
			@withdrawal.admin_id = current_admin.id
			@withdrawal.note = params[:note]
			if @withdrawal.save

				TransactionalMailer.withdrawal_approved(@withdrawal).deliver
				AdminActivity.create(admin_id: current_admin.id,
									data: YAML.dump({
										type: 'Accepted Withdrawal',
										message: "#{current_admin.name} accepted a withdrawal.",
										rep_id: @withdrawal.sales_rep_id,
										wd_id: @withdrawal.id
									}))
			end
		else
			render status: 403
		end
	end

	def deny_request
		if current_admin.authorized_to?('authorize_withdrawal')
			@withdrawal = Withdrawal.find(params[:id])
			@withdrawal.status = 'Denied'
			@withdrawal.approved = DateTime.now
			@withdrawal.admin_id = current_admin.id
			@withdrawal.note = params[:note]
			if @withdrawal.save

				TransactionalMailer.withdrawal_denied(@withdrawal).deliver
				AdminActivity.create(admin_id: current_admin.id,
									data: YAML.dump({
										type: 'Denied Withdrawal',
										message: "#{current_admin.name} denied a withdrawal.",
										rep_id: @withdrawal.sales_rep_id,
										wd_id: @withdrawal.id
									}))
			end
		else
			render status: 403
		end
	end






	def update_rep_profile
		if current_admin.authorized_to?('manage_rep')
			@rep = SalesRepresentative.find(params[:id])
			@rep.first_name = params[:first_name]
			@rep.last_name = params[:last_name]
			@rep.email = params[:email]
			if @rep.save
				AdminActivity.create(admin_id: current_admin.id,
									data: YAML.dump({
										type: 'Updated Representative',
										message: "#{current_admin.name} a Sales Rep account.",
										rep_id: @rep.id
									}))
			end
		else
			render status: 403
		end
	end

	def update_rep_mailing
		if current_admin.authorized_to?('manage_rep')
			@rep = SalesRepresentative.find(params[:id])
			@rep.address_1 = params[:address_1]
			@rep.address_2 = params[:address_2]
			@rep.city = params[:city]
			@rep.state = params[:state]
			@rep.country = params[:country]
			@rep.zip = params[:zip]

			@rep.save
		else
			render status: 403
		end
	end

	def update_rep_commission
		if current_admin.authorized_to?('manage_rep')
			@rep = SalesRepresentative.find(params[:id])
			@rep.commission_rate = params[:new_rate]

			@rep.save
		else
			render status: 403
		end
	end


	def rep_pending_balance
		if current_admin.authorized_to?('manage_rep')
			@balance = SalesRepresentative.find(params[:rep_id]).pending_balance
		else
			render status: 403
		end
	end
	def rep_current_balance
		if current_admin.authorized_to?('manage_rep')
			@balance = SalesRepresentative.find(params[:rep_id]).current_balance
		else
			render status: 403
		end
	end
	def rep_pending_withdrawals
		if current_admin.authorized_to?('manage_rep')
			@balance = SalesRepresentative.find(params[:rep_id]).pending_withdrawals
		else
			render status: 403
		end
	end
	def rep_total_payout
		if current_admin.authorized_to?('manage_rep')
			@balance = SalesRepresentative.find(params[:rep_id]).total_payout
		else
			render status: 403
		end
	end


	def view_pending_balance_details
		if current_admin.authorized_to?('manage_rep')
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
		else
			render status: 403
		end
	end

	def view_current_balance_details
		if current_admin.authorized_to?('manage_rep')
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
		else
			render status: 403
		end
	end

	def view_pending_withdrawals_details
		if current_admin.authorized_to?('manage_rep')
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
		else
			render status: 403
		end
	end
	def view_total_payout_details
		if current_admin.authorized_to?('manage_rep')
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
		else
			render status: 403
		end
	end


	def view_withdrawal_invoice
		if current_admin.authorized_to?('manage_rep')
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
		else
			flash[:error] = 'You are not authorized to view that.'
			redirect_to '/admins'
		end
	end

	def view_transactions_over_period
		if current_admin.authorized_to?('manage_rep')
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
		else
			flash[:error] = 'You are not authorized to view that.'
			redirect_to '/admins'
		end
	end

	def update_invoice_details
		if current_admin.authorized_to?('update_plan_invoice')
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
		else
			render status: 403
		end
	end

	def upload_invoice_logo
		if current_admin.authorized_to?('update_plan_invoice')
			@logo = InvoiceLogo.first
			@logo.image = params[:image]

			if @logo.save
				@success = true
			else
				render status: 500
			end
		else
			render status: 403
		end
	end

	def user_payment_queue
		if current_admin.authorized_to?('update_plan_invoice')
			@transactions = Transaction.where(status: 'Pending')
		else
			render status: 403
		end
	end

	def roles
		if current_admin.authorized_to?('edit_permissions')
			@roles = AdminRole.all.order(name: :asc)
		else
			flash[:error] = 'You are not authorized to view that.'
			redirect_to '/admins' and return
		end
	end

	def create_admin_role
		if current_admin.authorized_to?('edit_permissions')
			@role = AdminRole.new(params)
			if @role.save
				flash[:success] = 'Admin role created!'
			end
		else
			render status: 403
		end
	end

	def new_admin_role
		if current_admin.authorized_to?('edit_permissions')
			@roles = AdminRole.all.order(name: :asc)
		else
			flash[:error] = 'You are not authorized to view that.'
			redirect_to '/admins' and return
		end
	end

	def role
		if current_admin.authorized_to?('edit_permissions')
			@role = AdminRole.find(params[:id])
			@roles = AdminRole.all.order(name: :asc)
		else
			flash[:error] = 'You are not authorized to view that.'
			redirect_to '/admins' and return
		end
	end

	def delete_role
		if current_admin.authorized_to?('edit_permissions')
			@role = AdminRole.find(params[:id])

			admins = Admin.where(role_id: params[:id])

			admins.each do |admin|
				cases = SupportCase.where(admin_id: admin.id)
				cases.each do |sc|
					sc.admin_id = nil
					if sc.status == 'Open'
						sc.status = 'Pending'
					end
					sc.save
				end
				Resque.enqueue(AdminNotifier, admin.id, 'system', "Your role has been changed. View your account for new permissions details.", '/admins/manage_admins/view/'+admin.id.to_s)
			end

			@role.destroy
			redirect_to admin_roles_path and return
		else
			flash[:error] = 'You are not authorized to view that.'
			redirect_to '/admins' and return
		end
	end

	def update_role
		if current_admin.authorized_to?('edit_permissions')
			@role = AdminRole.find(params[:id])
			@role.create_user = params[:create_user]
			@role.manage_user = params[:manage_user]
			@role.create_rep = params[:create_rep]
			@role.manage_rep = params[:manage_rep]
			@role.create_admin = params[:create_admin]
			@role.manage_admin = params[:manage_admin]

			@role.update_plan_invoice = params[:update_plan_invoice]
			@role.accept_cancel_payment = params[:accept_cancel_payment]
			@role.authorize_withdrawal = params[:authorize_withdrawal]

			@role.update_videos = params[:update_videos]
			@role.update_mail_settings = params[:update_mail_settings]
			@role.manage_support_tickets = params[:manage_support_tickets]

				admins = Admin.where(role_id: params[:id])

				admins.each do |admin|
					cases = SupportCase.where(admin_id: admin.id)
					cases.each do |sc|
						sc.admin_id = nil
						if sc.status == 'Open'
							sc.status = 'Pending'
						end
						sc.save
					end
					Resque.enqueue(AdminNotifier, admin.id, 'system', "Your role has been changed. View your account for new permissions details.", '/admins/manage_admins/view/'+admin.id.to_s)
				end
		else
			render status: 403
		end
	end

	def mail_settings
		@templates = MailTemplate.all.order(name: :asc)
		@smtp = YAML.load(Setting.where(name: 'SMTP Credentials').first.data)
		@mailchimp = YAML.load(Setting.where(name: 'MailChimp Credentials').first.data)
		@send_address = Setting.where(name: 'Default Send Address').first.data
	end

	def update_smtp
		@smtp_settings = Setting.where(name: 'SMTP Credentials').first
		data = YAML.load(@smtp_settings.data)

		if params[:address].present? && params[:port].present? && params[:user_name].present? && params[:password].present? && params[:domain].present?
			data[:address] = params[:address]
			data[:port] = params[:port]
			data[:user_name] = params[:user_name]
			data[:password] = params[:password]
			data[:domain] = params[:domain]

			ActionMailer::Base.smtp_settings = {
				:address   => params[:address],
				:port      => params[:port],
				:user_name => params[:user_name],
				:password  => params[:password],
				:domain    => params[:domain]
			}

			@smtp_settings.data = YAML.dump(data)
			@smtp_settings.save

			@success = true
			@message = 'The SMTP settings have been saved.'
		else
			@success = false
			@message = 'You must fill out all fields to update this setting.'
		end
	end

	def update_mailchimp
		@mailchimp = Setting.where(name: 'MailChimp Credentials').first
		data = YAML.load(@mailchimp.data)

		if params[:api_key].present? && params[:list_id].present?
			data[:api_key] = params[:api_key]
			data[:list_id] = params[:list_id]

			@mailchimp.data = YAML.dump(data)
			@mailchimp.save

			@success = true
			@message = 'The MailChimp settings have been saved.'
		else
			@success = false
			@message = 'You must fill out all fields to update this setting.'
		end
	end

	def update_send_address
		@send_address = Setting.where(name: 'Default Send Address').first
		if params[:send_address].present?
			@send_address.data = params[:send_address]
			@send_address.save
			@success = true
			@message = 'The default sending address has been updated.'
		else
			@success = false
			@message = 'You must fill out the field to update this setting.'
		end
	end

	def mail_markup
		@templates = MailTemplate.all.order(name: :asc)
		@css = Setting.where(name: 'Mail Global CSS').first.data
		@header = Setting.where(name: 'Mail Header Markup').first.data
		@footer = Setting.where(name: 'Mail Footer Markup').first.data
	end

	def update_mail_css
		@css = Setting.where(name: 'Mail Global CSS').first
		@css.data = params[:css]
		@css.save
	end

	def update_mail_header
		@header = Setting.where(name: 'Mail Header Markup').first
		@header.data = params[:header]
		@header.save
	end

	def update_mail_footer
		@footer = Setting.where(name: 'Mail Footer Markup').first
		@footer.data = params[:footer]
		@footer.save
	end

	def mail_template
		@templates = MailTemplate.all.order(name: :asc)
		@template = MailTemplate.find(params[:id])
		@variables = YAML.load(@template.required_variables)
	end

	def update_mail_template_body
		@template = MailTemplate.find(params[:id])

		@variables = YAML.load(@template.required_variables)
		@variables_present = Hash.new
		all_present = true

		if params[:body].present?
			@variables.each do |var|
				if params[:body].include?("*|#{var.upcase}|*")
					@variables_present[var.to_sym] = true
				else
					@variables_present[var.to_sym] = false
					all_present = false
				end
			end
		else
			all_present = false
			@variables.each do |var|
				@variables_present[var.to_sym] = false
			end
		end

		if all_present == true
			@template.body = params[:body]
			@template.save
			@success = true
		else
			@success = false
		end
	end

	def update_mail_template_css
		@template = MailTemplate.find(params[:id])
		@template.css = params[:css]
		@template.save
	end

	def update_mail_template_subject
		@template = MailTemplate.find(params[:id])
		@template.subject = params[:subject]
		@template.save
	end

	def manage_admins
		if current_admin.authorized_to?('manage_admin')
			@admins = Admin.all
		else
			flash[:error] = 'You are not allowed to view that.'
			redirect_to '/admins' and return
		end
	end

	def view_admin
		if current_admin.authorized_to?('manage_admin') || params[:id].to_i == current_admin.id
			@admin = Admin.find(params[:id])
			roles = AdminRole.all.order(name: :desc)
			@roles_array = Array.new

			roles.each do |role|
				@roles_array.push([role.name, role.id])
			end
		else
			flash[:error] = 'You are not allowed to view that.'
			redirect_to '/admins' and return
		end
	end

	def update_admin
		if current_admin.id == params[:id] || current_admin.authorized_to?('manage_admin')
			@admin = Admin.find(params[:id])

			if current_admin.role == 'Root'
				@admin.first_name = params[:first_name]
				@admin.last_name = params[:last_name]
				@admin.email = params[:email]
				@admin.role_id = params[:role_id]
				@admin.timezone = params[:timezone]
				@admin.save
			elsif @admin.role == 'Root'
				render status: 403
			else
				@admin.first_name = params[:first_name]
				@admin.last_name = params[:last_name]
				@admin.email = params[:email]
				if current_admin.authorized_to?('manage_admin')
					@admin.role_id = params[:role_id]
				end
				if @admin.role_id == 0
					@admin.errors.add(:role_id, "can't be made Root by a non-root Admin")
				else
					@admin.save
				end
			end
			unless @admin.id == current_admin.id
				Resque.enqueue(AdminNotifier, @admin.id, 'system', "Your account has been modified. View your account for new permissions details.", '/admins/manage_admins/view/'+@admin.id.to_s)
			end
		else
			render status: 403
		end
	end

	def send_password_reset
		if current_admin.authorized_to?('manage_admin')
			admin = Admin.find(params[:id])
			if current_admin.role == 'Root'
				admin.send_reset_password_instructions
				@success = true
			elsif admin.role == 'Root'
				@success = false
			end
		else
			render status: 403
		end
	end

	def new_admin
		if current_admin.authorized_to?('create_admin')
			roles = AdminRole.all.order(name: :desc)
			@roles_array = Array.new

			roles.each do |role|
				@roles_array.push([role.name, role.id])
			end
		else
			flash[:error] = 'You are not authorized to do that.'
			redirect_to '/admins' and return
		end
	end

	def create_admin
		if current_admin.authorized_to?('create_admin')
			@admin = Admin.new(params)
			if current_admin.role != 'Root' && params[:role_id] == 0
				@admin.errors.add(:role_id, "can't be made Root by non-root Admin")
			else
				password = SecureRandom.hex(7)
				@admin.password = password
				if @admin.save
					TransactionalMailer.admin_register_admin(@admin,password).deliver
					flash[:success] = 'Admin created.'
				end
			end
		else
			render status: 403
		end
	end

	def add_subscription
		@plan = Plan.find(params[:plan_id])

		if params[:serial].present?
			@device = Roku.new
			@device.user_id = current_user.id
			@device.serial = params[:serial]

			if @device.valid? && current_user.max_devices?
				@device_errors = true
				@device.errors.add(:base, 'You have reached the maximum number of devices allowed.')
			elsif @device.valid?
				@device_errors = false
			else
				@device_errors = true
			end
		else
			@device = nil
			@device_errors = false
		end

		if @device_errors == false
			if params[:refer_code].present?
				friend = User.where(refer_code: params[:refer_code]).first
				if friend.nil? || friend.id == current_user.id
					@referral_errors = true
					@referral_message = 'This referral code is not valid.'
				else
					@referral_errors = false
				end
			else
				friend = nil
				@referral_errors = false
			end
		end

		if @device_errors == false && @referral_errors == false
			total = @plan.price - current_user.balance

			if total > 0 && params[:payment_type].present?
				if params[:payment_type] == 'Credit Card'
					# Send requests to the gateway's test servers
					ActiveMerchant::Billing::Base.mode = :test

					# Create a new credit card object
					credit_card = ActiveMerchant::Billing::CreditCard.new(
						:number     => params[:card],
						:month      => params[:card_month],
						:year       => params[:card_year],
						:first_name => params[:card_first_name],
						:last_name  => params[:card_last_name],
						:verification_value  => params[:ccv]
					)

					if credit_card.valid?
						@paypal = YAML.load(Setting.where(name: 'Paypal Credentials').first.data)
						gateway = ActiveMerchant::Billing::PaypalGateway.new(
							login:    	@paypal[:login],
							password: 	@paypal[:password],
							signature: 	@paypal[:signature]
						)





						response = gateway.purchase((total*100).to_i, credit_card, ip: request.remote_ip)

						if response.success?
							user = current_user
							user.balance = 0
							if user.expiry.nil? || user.expiry < Date.today
								user.expiry = Date.today + @plan.months.months
							else
								user.expiry += @plan.months.months
							end
							user.save
							transaction = Transaction.new
							transaction.user_id = user.id
							transaction.payment_type = 'Credit Card'
							transaction.paypal_id = response.params['transaction_id']
							transaction.status = 'Paid'
							transaction.customer_paid = DateTime.now
							unless friend.nil?
								transaction.product_details = YAML.dump({name: @plan.name, duration: @plan.months, price: @plan.price, refer_code: params[:refer_code], friend_id: friend.id})
								@referral_bonus = YAML.load(Setting.where(name: 'Referral Bonus').first.data)
								if @referral_bonus[:method] == 'Lump Sum'
									friend.balance += @referral_bonus[:rate]
								else
									new_balance = (@referral_bonus[:rate]/100) * @plan.price
									friend.balance += (new_balance * 100).round / 100
								end
								friend.save
							else
								transaction.product_details = YAML.dump({name: @plan.name, duration: @plan.months, price: @plan.price})
							end
							unless @device.nil?
								transaction.roku_id = @device.id
								@device.save
							end
							transaction.balance_used = @plan.price - total
							transaction.save
							@success = true
							flash[:success] = 'Your subscription has been successfully processed.'
							TransactionalMailer.order_paid(transaction)
						else
							@payment_errors = true
							@payment_message = response.message
						end
					else
						@payment_errors = true
						@payment_message = 'This credit card is not valid.'
					end
				else
					user = current_user
					user.balance = 0
					if user.expiry.nil? || user.expiry < Date.today
						user.expiry = Date.today + @plan.months.months
					else
						user.expiry += @plan.months.months
					end
					user.save
					transaction = Transaction.new
					transaction.payment_type = params[:payment_type]
					transaction.status = 'Pending'
					unless friend.nil?
						transaction.product_details = YAML.dump({name: @plan.name, duration: @plan.months, price: @plan.price, refer_code: params[:refer_code], friend_id: friend.id})
						@referral_bonus = YAML.load(Setting.where(name: 'Referral Bonus').first.data)
						if @referral_bonus[:method] == 'Lump Sum'
							friend.balance += @referral_bonus[:rate]
						else
							new_balance = (@referral_bonus[:rate]/100) * @plan.price
							friend.balance += (new_balance * 100).round / 100
						end
						friend.save
					else
						transaction.product_details = YAML.dump({name: @plan.name, duration: @plan.months, price: @plan.price})
					end
					transaction.balance_used = @plan.price - total
					transaction.save
					flash[:success] = 'Your order has been processed. Please send your payment to activate your subscription.'
					TransactionalMailer.order_completed(transaction)
				end
			elsif total <= 0
				user = current_user
				user.balance = user.balance - @plan.price
				if user.expiry.nil? || user.expiry < Date.today
					user.expiry = Date.today + @plan.months.months
				else
					user.expiry += @plan.months.months
				end
				user.save
				transaction = Transaction.new
				transaction.user_id = user.id
				transaction.payment_type = 'Previous Balance'
				transaction.status = 'Paid'
				transaction.balance_used = @plan.price
				unless friend.nil?
					transaction.product_details = YAML.dump({name: @plan.name, duration: @plan.months, price: @plan.price, refer_code: params[:refer_code], friend_id: friend.id})
					@referral_bonus = YAML.load(Setting.where(name: 'Referral Bonus').first.data)
					if @referral_bonus[:method] == 'Lump Sum'
						friend.balance += @referral_bonus[:rate]
					else
						new_balance = (@referral_bonus[:rate]/100) * @plan.price
						friend.balance += (new_balance * 100).round / 100
					end
					friend.save
				else
					transaction.product_details = YAML.dump({name: @plan.name, duration: @plan.months, price: @plan.price})
				end
				unless @device.nil?
					transaction.roku_id = @device.id
					@device.save
				end
				transaction.save
			else
				@payment_errors = true
				@payment_message = 'You must select a payment type.'
			end
		end
	end

	def general_settings
		unless current_admin.authorized_to?('edit_general_settings')
			flash[:error] = 'You are not allowed to view that.'
			redirect_to '/admins'
		end
	end

	def edit_timezone
		unless current_admin.authorized_to?('edit_general_settings')
			flash[:error] = 'You are not allowed to view that.'
			redirect_to '/admins'
		end
		@current_zone = Setting.where(name: 'Default Timezone').first.data
	end

	def update_default_timezone
		unless current_admin.authorized_to?('edit_general_settings')
			flash[:error] = 'You are not allowed to view that.'
			redirect_to '/admins'
		end
		if params[:timezone].present? && params[:timezone] != 'Select A Timezone'
			timezone = Setting.where(name: 'Default Timezone').first
			old = timezone.data
			timezone.data = params[:timezone]
			if timezone.save
				flash[:success] = 'Successfully updated time zone!'

				AdminActivity.create(admin_id: current_admin.id,
									data: YAML.dump({
										type: 'Timezone Updated',
										message: "#{current_admin.name} denied a withdrawal.",
										old_zone: old,
										new_zone: timezone.data
									}))
			end
		else
			flash[:error] = 'There was an error updating the time zone.'
		end
		redirect_to edit_timezone_path
	end

	def edit_device_limit
		unless current_admin.authorized_to?('edit_general_settings')
			flash[:error] = 'You are not allowed to view that.'
			redirect_to '/admins'
		end
		@current_limit = Setting.where(name: 'Device Limit').first.data
	end

	def update_device_limit
		unless current_admin.authorized_to?('edit_general_settings')
			flash[:error] = 'You are not allowed to view that.'
			redirect_to '/admins'
		end
		if params[:device_limit].present?
			limit = Setting.where(name: 'Device Limit').first
			limit.data = params[:device_limit]
			limit.save
			flash[:success] = 'Successfully updated device limit!'
		else
			flash[:error] = 'There was an error updating the limit.'
		end
		redirect_to edit_device_limit_path
	end

	def edit_free_trial
		unless current_admin.authorized_to?('edit_general_settings')
			flash[:error] = 'You are not allowed to view that.'
			redirect_to '/admins'
		end
		@current_length = Setting.where(name: 'Free Trial Length').first.data
	end

	def update_free_trial
		unless current_admin.authorized_to?('edit_general_settings')
			flash[:error] = 'You are not allowed to view that.'
			redirect_to '/admins'
		end
		if params[:free_trial_length].present?
			length = Setting.where(name: 'Free Trial Length').first
			length.data = params[:free_trial_length]
			length.save
			flash[:success] = 'Successfully updated trial length!'
		else
			flash[:error] = 'There was an error updating the trial.'
		end
		redirect_to edit_free_trial_path
	end

	def edit_wd_limits
		unless current_admin.authorized_to?('edit_general_settings')
			flash[:error] = 'You are not allowed to view that.'
			redirect_to '/admins'
		end
		@limits = YAML.load(Setting.where(name: 'Withdrawal Limits').first.data)
	end

	def update_lower_wd_limit
		unless current_admin.authorized_to?('edit_general_settings')
			flash[:error] = 'You are not allowed to view that.'
			redirect_to '/admins'
		end
		if params[:min].present?
			limits = Setting.where(name: 'Withdrawal Limits').first
			details = YAML.load(limits.data)
			details[:min] = params[:min]
			limits.data = YAML.dump(details)
			limits.save
			flash[:success] = 'Successfully updated minimum withdrawal!'
		else
			flash[:error] = 'There was an error updating the limit.'
		end
		redirect_to edit_wd_limits_path
	end

	def update_upper_wd_limit
		unless current_admin.authorized_to?('edit_general_settings')
			flash[:error] = 'You are not allowed to view that.'
			redirect_to '/admins'
		end
		if params[:max].present?
			limits = Setting.where(name: 'Withdrawal Limits').first
			details = YAML.load(limits.data)
			details[:max] = params[:max]
			limits.data = YAML.dump(details)
			limits.save
			flash[:success] = 'Successfully updated minimum withdrawal!'
		else
			flash[:error] = 'There was an error updating the limit.'
		end
		redirect_to edit_wd_limits_path
	end

	def update_user_balance
		@user = User.find(params[:user_id])
		prev_balance = @user.balance

		if @user.balance.nil?
			@user.balance = params[:add_balance].to_f
		else
			@user.balance += params[:add_balance].to_f
		end
		if @user.save
			AdminActivity.create(admin_id: current_admin.id,
								data: YAML.dump({
									type: 'Balance Adjustment',
									message: "#{current_admin.name} added funds to a balance.",
									user_id: @user.id,
									prev_balance: prev_balance,
									new_balance: @user.balance
								}))
		end
	end
end
