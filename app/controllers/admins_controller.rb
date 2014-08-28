class AdminsController < ApplicationController
	def view_vod_upload
		@migration = Grid.find(params[:id])
		@migration_items = VodMigrationItem.where(migration_id: @migration.id)
	end

	def index
		@data = DailyData.where(date: Date.today).last
		if @data.nil?
			@data = DailyData.new(date: Date.today, ).last
		end

	end
	def new_user
		unless current_admin.authorized_to?('create_user')

			flash[:error] = 'You are not authorized to view that.'
			redirect_to '/admins'
		end
	end

	def remove_admin
		if current_admin.role_id == 0
			Admin.where(id: params[:id]).first.destroy
			flash[:success] = 'Admin has been deleted.'
			redirect_to '/admins/manage_admins'
		else
			render status: 403
		end
	end

	def delete_user
		if current_admin.authorized_to?('manage_user')
			user = User.find(params[:id])
			devices = Device.where(user_id: user.id)

			user.destroy
			if devices.any?
				devices.destroy_all
			end

			flash[:success] = 'Client has been deleted'
			redirect_to '/admins/users'
		else

			flash[:error] = 'You are not authorized to view that.'
			redirect_to '/admins'
		end
	end

	def delete_rep
		if current_admin.authorized_to?('manage_user')
			rep = SalesRepresentative.find(params[:id])
			rep.destroy

			flash[:success] = 'Representative has been deleted'
			redirect_to '/admins/sales_reps'
		else
			flash[:error] = 'You are not authorized to view that.'
			redirect_to '/admins'
		end
	end

	def create_user
		@user = User.where(id: params[:user_id]).first

		if @user.nil?
			@user = User.new
		end
		@user.first_name = params[:first_name]
		@user.last_name = params[:last_name]
		@user.email = params[:email]
		@user.phone = params[:phone]
		@user.mobile_phone = params[:mobile_phone]
		@user.address_1 = params[:address_1]
		@user.address_2 = params[:address_2]
		@user.country = params[:country]
		@user.state = params[:state]
		@user.city = params[:city]
		@user.zip = params[:zip]


		code = SecureRandom.hex(5).upcase
		until User.where(refer_code: code).count < 1
			code = SecureRandom.hex(5).upcase
		end

		@user.refer_code = code

		@user.password = params[:password]

		if @user.save
			@user_errors = false
			if params[:device_to_add] == 'true'
				@device = Device.where(id: params[:device_id]).first
				if @device.nil?
					@device = Device.new
				end
				@device.serial = params[:serial].upcase
				if @device.serial.include?('O')
					@device.serial = @device.serial.gsub!('O','0')
				end
				@device.name = params[:name]
				@device.user_id = @user.id
				@device.type = 'Roku'
				if @device.save
					if Rails.env.development?
						path = "#{Rails.root}/serials/#{@device.serial}"
					elsif Rails.env.production?
						path = "/tmp/serials/#{@device.serial}"
					end

					serial_file = File.open(path,'w+')
					@device.serial_file = serial_file
					@device.save
					@device_errors = false
				else
					@device_errors = true
					@device_error = 'Serial ' + @device.errors[:serial].join(', ')
				end
			else
				@device_errors = false
				@device = nil
			end
			if params[:note_to_add] == 'true' && @device_errors == false
				@note = UserNote.where(id: params[:note_id]).first
				if @note.nil?
					@note = UserNote.new
				end
				@note.user_id = @user.id
				@note.title = params[:note_title]
				@note.note = params[:note]
				@note.note_colour = params[:color]
				if params[:check_item].present?
					checklist = Array.new
					params[:check_item].each_with_index do |item, i|
						array = Array.new
						if item.blank?
							array.push(nil)
						else
							array.push(item)
						end
						checklist.push(array)
					end
					params[:check_status].each_with_index do |status, i|
						checklist[i].push(status)
					end

					checklist.delete([nil,'complete'])
					checklist.delete([nil,'incomplete'])

				else
					checklist = Array.new
				end

				if params[:list_item].present?
					reglist = Array.new
					params[:list_item].each_with_index do |item, i|
						array = Array.new
						if item.blank?
							reglist.push(nil)
						else
							reglist.push(item)
						end
					end

					reglist.delete(nil)
				else
					reglist = Array.new
				end

				@note.checklist = YAML.dump({checklist: checklist, reglist: reglist})

				if @note.save
					@note_errors = false
				else
					@note_errors = true
				end
			else
				@note_errors = false
			end

			if params[:tx_to_process] == 'true' && @device_errors == false && @note_errors == false && params[:plan_id].present?
				@test1 = 'filter'
				@plan = Plan.find(params[:plan_id])
				if params[:payment_type] == 'Credit Card'

					@test2 = 'credit card'
					# Send requests to the gateway's test servers
					ActiveMerchant::Billing::Base.mode = :test

					# Create a new credit card object

					names = params[:card_name].split(' ', 2)
					credit_card = ActiveMerchant::Billing::CreditCard.new(
						:number     => params[:card_number],
						:month      => params[:card_month],
						:year       => params[:card_year],
						:first_name => names[0],
						:last_name  => names[1],
						:verification_value  => params[:ccv]
					)

					if credit_card.valid?
						@paypal = YAML.load(Setting.where(name: 'Paypal Credentials').first.data)
						gateway = ActiveMerchant::Billing::PaypalGateway.new(
							login:    	@paypal[:login],
							password: 	@paypal[:password],
							signature: 	@paypal[:signature]
						)

						response = gateway.purchase((@plan.price*100).to_i, credit_card, ip: request.remote_ip)

						if response.success?
							@device.save
							transaction = Transaction.new
							transaction.user_id = @user.id
							transaction.payment_type = 'Credit Card'
							transaction.paypal_id = response.params['transaction_id']
							transaction.status = 'Paid'
							transaction.customer_paid = DateTime.now
							unless @device.nil?
								transaction.roku_id = @device.id
								@device.expiry = Date.today + @plan.months.months
							else
								@user.expiry = Date.today + @plan.months.months
							end
							transaction.product_details = YAML.dump({name: @plan.name, duration: @plan.months, price: @plan.price})
							transaction.plan_id = @plan.id


							transaction.balance_used = 0
							transaction.save
							OrderNotification.create(transaction_id: transaction.id,message: "Order \##{transaction.id} has been created and paid.", link: true)
							@tx_errors = false
						else
							@tx_errors = true
							@tx_error = response.message
						end
					else
						@tx_errors = true
						@tx_error = 'This credit card is not valid'
					end
				elsif params[:payment_type].present?
					@test2 = 'non credit card'
					transaction = Transaction.new
					transaction.user_id = @user.id
					transaction.payment_type = params[:payment_type]
					transaction.status = 'Pending'
					transaction.product_details = YAML.dump({name: @plan.name, duration: @plan.months, price: @plan.price})
					transaction.balance_used = 0
					transaction.plan_id = @plan.id
					unless @device.nil?
						transaction.roku_id = @device.id
					end
					transaction.save
					OrderNotification.create(transaction_id: transaction.id,message: "Order \##{transaction.id} has been created.", link: true)
					@tx_errors = false
				else
					@test2 = 'no payment type'
					@tx_errors = true
					@test3 = @tx_errors
					@tx_error = 'You must choose a payment type.'
				end
			elsif @device_errors == false && @note_errors == false
				@tx_errors = false
				length = Setting.where(name: 'Free Trial Length').first.data
				@device.expiry = Date.today + length.to_i.days
				@device.save
				transaction = Transaction.new
				transaction.user_id = @user.id
				transaction.payment_type = params[:payment_type]
				transaction.status = 'Paid'
				transaction.customer_paid = DateTime.now
				transaction.product_details = YAML.dump({name: 'Free Trial', duration: length, price: 0})
				transaction.balance_used = 0
				transaction.save
			else
				@tx_errors = false
			end
		else
			@user_errors = true
		end
		if @user_errors == false && @device_errors == false && @note_errors == false && @tx_errors == false
			TransactionalMailer.admin_register_customer(@user, params[:password]).deliver
			update = AdminActivity.create(admin_id: current_admin.id, data: YAML.dump({type: 'User Registration', message: "#{current_admin.name} registered a new user.", user_id: @user.id}))
			Resque.enqueue(AdminNotifier, 0, 'system', "#{@user.name} has joined.", view_user_path(id: @user.id))

			if transaction.payment_type == 'Credit Card'
				TransactionalMailer.order_paid(transaction, @user).deliver
			else
				TransactionalMailer.order_created(transaction, @user).deliver
			end
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
		if current_admin.authorized_to?('manage_user')
			all_users = User.all.order(first_name: :desc)
			@matched_users = User.search(params[:search])
		else
			render status: 403
		end
	end

	def search_users_for_ticket_order
		if params[:search_type] == 'user'
			all_users = User.all.order(first_name: :desc)
			@matched_users = User.search(params[:search])
		else
			all_users = SalesRepresentative.all.order(first_name: :desc)
			@matched_users = SalesRepresentative.search(params[:search])
		end
	end

	def view_user
		if current_admin.authorized_to?('manage_user')
			@user = User.find(params[:id])
			if @user.balance.nil?
				@user.balance = 0
				@user.save
			end
			@devices = Device.where(user_id: @user.id)
			@transactions = Transaction.where(user_id: @user.id)

			@total_spent = 0
			@pending = 0
			@transactions.each do |tx|
				if tx.status == 'Pending'
					@pending += YAML.load(tx.product_details)[:price]
				elsif tx.status == 'Paid' || tx.status == 'Refunded'
					@total_spent += YAML.load(tx.product_details)[:price]
				end
			end
			@notes = UserNote.where(user_id: @user.id).order(updated_at: :desc)
		else
			flash[:error] = 'You do not have permission to view that.'
			redirect_to '/admins'
		end
	end
	def view_user_transactions
		if current_admin.authorized_to?('manage_user')
			@user = User.find(params[:id])
			if @user.balance.nil?
				@user.balance = 0
				@user.save
			end
			@devices = Device.where(user_id: @user.id)
			@transactions = Transaction.where(user_id: @user.id)

			@total_spent = 0
			@pending = 0
			@transactions.each do |tx|
				if tx.status == 'Pending'
					@pending += YAML.load(tx.product_details)[:price]
				elsif tx.status == 'Paid' || tx.status == 'Refunded'
					@total_spent += YAML.load(tx.product_details)[:price]
				end
			end
			@notes = UserNote.where(user_id: @user.id).order(updated_at: :desc)
		else
			flash[:error] = 'You do not have permission to view that.'
			redirect_to '/admins'
		end
	end
	def view_user_notes
		if current_admin.authorized_to?('manage_user')
			@user = User.find(params[:id])
			if @user.balance.nil?
				@user.balance = 0
				@user.save
			end
			@devices = Device.where(user_id: @user.id)
			@transactions = Transaction.where(user_id: @user.id)

			@total_spent = 0
			@pending = 0
			@transactions.each do |tx|
				if tx.status == 'Pending'
					@pending += YAML.load(tx.product_details)[:price]
				elsif tx.status == 'Paid' || tx.status == 'Refunded'
					@total_spent += YAML.load(tx.product_details)[:price]
				end
			end
			@notes = UserNote.where(user_id: @user.id).order(updated_at: :desc)
		else
			flash[:error] = 'You do not have permission to view that.'
			redirect_to '/admins'
		end
	end
	def view_user_devices
		if current_admin.authorized_to?('manage_user')
			@user = User.find(params[:id])
			if @user.balance.nil?
				@user.balance = 0
				@user.save
			end
			@devices = Device.where(user_id: @user.id)
			@transactions = Transaction.where(user_id: @user.id)

			@total_spent = 0
			@pending = 0
			@transactions.each do |tx|
				if tx.status == 'Pending'
					@pending += YAML.load(tx.product_details)[:price]
				elsif tx.status == 'Paid' || tx.status == 'Refunded'
					@total_spent += YAML.load(tx.product_details)[:price]
				end
			end
			@notes = UserNote.where(user_id: @user.id).order(updated_at: :desc)
		else
			flash[:error] = 'You do not have permission to view that.'
			redirect_to '/admins'
		end
	end
	def view_user_subscription
		if current_admin.authorized_to?('manage_user')
			@user = User.find(params[:id])
			if @user.balance.nil?
				@user.balance = 0
				@user.save
			end
			@devices = Device.where(user_id: @user.id)
			@transactions = Transaction.where(user_id: @user.id)

			@total_spent = 0
			@pending = 0
			@transactions.each do |tx|
				if tx.status == 'Pending'
					@pending += YAML.load(tx.product_details)[:price]
				elsif tx.status == 'Paid' || tx.status == 'Refunded'
					@total_spent += YAML.load(tx.product_details)[:price]
				end
			end
			@notes = UserNote.where(user_id: @user.id).order(updated_at: :desc)
		else
			flash[:error] = 'You do not have permission to view that.'
			redirect_to '/admins'
		end
	end
	def view_user_balance
		if current_admin.authorized_to?('manage_user')
			@user = User.find(params[:id])
			if @user.balance.nil?
				@user.balance = 0
				@user.save
			end
			@devices = Device.where(user_id: @user.id)
			@transactions = Transaction.where(user_id: @user.id)

			@total_spent = 0
			@pending = 0
			@transactions.each do |tx|
				if tx.status == 'Pending'
					@pending += YAML.load(tx.product_details)[:price]
				elsif tx.status == 'Paid' || tx.status == 'Refunded'
					@total_spent += YAML.load(tx.product_details)[:price]
				end
			end
			@notes = UserNote.where(user_id: @user.id).order(updated_at: :desc)
		else
			flash[:error] = 'You do not have permission to view that.'
			redirect_to '/admins'
		end
	end

	def add_subscription
		if params[:tx_serial].present? && params[:tx_serial].to_i != 0
			@device = Roku.where(id: params[:tx_serial]).first

			unless @device.nil?
				@user = User.find(params[:user_id])
				@plan = Plan.find(params[:plan_id])

				unless @user.balance.nil?
					total = @plan.price - @user.balance
				else
					total = @plan.price
				end

				if params[:payment_type].present?
					if total > 0
						if params[:payment_type] == 'Credit Card'
							ActiveMerchant::Billing::Base.mode = :test

							# Create a new credit card object
							names = params[:card_name].split(' ', 2)
							credit_card = ActiveMerchant::Billing::CreditCard.new(
								:number     => params[:card_number],
								:month      => params[:card_month],
								:year       => params[:card_year],
								:first_name => names[0],
								:last_name  => names[1],
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
									transaction = Transaction.new
									transaction.user_id = @user.id
									transaction.payment_type = 'Credit Card'
									transaction.paypal_id = response.params['transaction_id']
									transaction.status = 'Paid'
									transaction.customer_paid = DateTime.now
									transaction.balance_used = @user.balance
									transaction.roku_id = @device.id
									transaction.product_details = YAML.dump({name: @plan.name, duration: @plan.months, price: @plan.price})
									transaction.plan_id = @plan.id
									transaction.save

									OrderNotification.create(transaction_id: transaction.id,message: "Order \##{transaction.id} has been created and paid.", link: true)

									if @device.expiry.nil? || @device.expiry < Date.today
										@device.expiry = Date.today + @plan.months.months
									else
										@device.expiry += @plan.months.months
									end
									@device.save
									@user.balance = 0
									@user.save
									TransactionalMailer.order_paid(transaction, @user).deliver
									@tx_errors = false
								else
									@tx_errors = true
									@tx_error = response.message
								end
							else
								@tx_errors = true
								@tx_error = 'This card is not valid'
							end
						else
							transaction = Transaction.new
							transaction.user_id = @user.id
							transaction.payment_type = params[:payment_type]
							transaction.status = 'Pending'
							transaction.balance_used = @user.balance
							transaction.product_details = YAML.dump({name: @plan.name, duration: @plan.months, price: @plan.price})
							transaction.plan_id = @plan.id
							transaction.roku_id = @device.id
							transaction.save
							OrderNotification.create(transaction_id: transaction.id,message: "Order \##{transaction.id} has been created.", link: true)
							@user.balance = 0
							@user.save
							TransactionalMailer.order_created(transaction, @user).deliver
							@tx_errors = false
						end
					else
						@user.balance = @user.balance - @plan.price
						@user.save
						if @device.expiry.nil? || @device.expiry < Date.today
							@device.expiry = Date.today + @plan.months.months
						else
							@device.expiry += @plan.months.months
						end
						@device.save

						transaction = Transaction.new
						transaction.user_id = @user.id
						transaction.payment_type = 'Previous Balance'
						transaction.payment_type = params[:payment_type]
						transaction.status = 'Paid'
						transaction.customer_paid = DateTime.now
						transaction.balance_used = @plan.price
						transaction.roku_id = @device.id
						transaction.product_details = YAML.dump({name: @plan.name, duration: @plan.months, price: @plan.price})
						transaction.plan_id = @plan.id
						transaction.save
						OrderNotification.create(transaction_id: transaction.id,message: "Order \##{transaction.id} has been created and paid.", link: true)
						TransactionalMailer.order_paid(transaction, @user).deliver
						@tx_errors = false
					end
				else
					@tx_errors = true
					@tx_error = 'You must select a payment type'
				end
			else
				@device_errors = true
				@device_error = 'Only a Roku can add a subscription'
			end
		elsif params[:tx_serial].to_i == 0
			@user = User.find(params[:user_id])
			@plan = Plan.find(params[:plan_id])

			unless @user.balance.nil?
				total = @plan.price - @user.balance
			else
				total = @plan.price
			end

			if params[:payment_type].present?
				if total > 0
					if params[:payment_type] == 'Credit Card'
						ActiveMerchant::Billing::Base.mode = :test

						# Create a new credit card object
						names = params[:card_name].split(' ', 2)
						credit_card = ActiveMerchant::Billing::CreditCard.new(
							:number     => params[:card_number],
							:month      => params[:card_month],
							:year       => params[:card_year],
							:first_name => names[0],
							:last_name  => names[1],
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
								transaction = Transaction.new
								transaction.user_id = @user.id
								transaction.payment_type = 'Credit Card'
								transaction.paypal_id = response.params['transaction_id']
								transaction.status = 'Paid'
								transaction.customer_paid = DateTime.now
								transaction.balance_used = @user.balance
								transaction.product_details = YAML.dump({name: @plan.name, duration: @plan.months, price: @plan.price})
								transaction.plan_id = @plan.id
								transaction.save

								OrderNotification.create(transaction_id: transaction.id,message: "Order \##{transaction.id} has been created and paid.", link: true)

								if @user.expiry.nil? || @user.expiry < Date.today
									@user.expiry = Date.today + @plan.months.months
								else
									@user.expiry += @plan.months.months
								end
								@user.balance = 0
								@user.save
								TransactionalMailer.order_paid(transaction, @user).deliver
								@tx_errors = false
							else
								@tx_errors = true
								@tx_error = response.message
							end
						else
							@tx_errors = true
							@tx_error = 'This card is not valid'
						end
					else
						transaction = Transaction.new
						transaction.user_id = @user.id
						transaction.payment_type = params[:payment_type]
						transaction.status = 'Pending'
						transaction.balance_used = @user.balance
						transaction.product_details = YAML.dump({name: @plan.name, duration: @plan.months, price: @plan.price})
						transaction.plan_id = @plan.id
						transaction.save
						OrderNotification.create(transaction_id: transaction.id,message: "Order \##{transaction.id} has been created.", link: true)
						@user.balance = 0
						@user.save
						TransactionalMailer.order_created(transaction, @user).deliver
						@tx_errors = false
					end
				else
					@user.balance = @user.balance - @plan.price
					if @user.expiry.nil? || @user.expiry < Date.today
						@user.expiry = Date.today + @plan.months.months
					else
						@user.expiry += @plan.months.months
					end
					@user.save

					transaction = Transaction.new
					transaction.user_id = @user.id
					transaction.payment_type = 'Previous Balance'
					transaction.payment_type = params[:payment_type]
					transaction.status = 'Paid'
					transaction.customer_paid = DateTime.now
					transaction.balance_used = @plan.price
					transaction.product_details = YAML.dump({name: @plan.name, duration: @plan.months, price: @plan.price})
					transaction.plan_id = @plan.id
					transaction.save
					OrderNotification.create(transaction_id: transaction.id,message: "Order \##{transaction.id} has been created and paid.", link: true)
					TransactionalMailer.order_paid(transaction, @user).deliver
					@tx_errors = false
				end
			else
				@tx_errors = true
				@tx_error = 'You must select a payment type'
			end
		else
			@device_errors = true
			@device_error = 'You must select a Roku to continue'
		end

		if @device_errors == false && @tx_errors == false
			@transactions = Transaction.where(user_id: @user.id)
			@pending = 0
			@transactions.each do |tx|
				if tx.status == 'Pending'
					@pending += YAML.load(tx.product_details)[:price]
				end
			end
		end
	end



	def choose_plan
		if params[:roku_id].nil? == false && params[:roku_id].to_i != 0

			@device = Roku.find(params[:roku_id])
			@user = User.find(@device.user_id)
			@plan = Plan.find(params[:plan_id])

			unless @user.balance.nil?
				@total = @plan.price - @user.balance
			else
				@total = @plan.price
				@user.balance = 0
				@user.save
			end
		elsif params[:roku_id].to_i == 0
			@user = User.find(params[:user_id])
			@plan = Plan.find(params[:plan_id])
			unless @user.balance.nil?
				@total = @plan.price - @user.balance
			else
				@total = @plan.price
				@user.balance = 0
				@user.save
			end
		else
			@device = nil
			@plan = Plan.find(params[:plan_id])
			if params[:user_id].present?
				@user = User.find(params[:user_id])
				unless @user.balance.nil?
					@total = @plan.price - @user.balance
				else
					@total = @plan.price
					@user.balance = 0
					@user.save
				end
			else
				@user = User.new
				@user.balance = 0

				@total = @plan.price
			end
		end
	end

	def update_user_profile
		if current_admin.authorized_to?('manage_user')
			@user = User.find(params[:id])
			@user.first_name = params[:first_name]
			@user.last_name = params[:last_name]
			@user.email = params[:email]
			@user.adult = params[:adult]
			@user.save
		else
			render status: 403
		end
	end

	def update_user_mailing
		if current_admin.authorized_to?('manage_user')
			@user = User.find(params[:id])
			@user.mobile_phone = params[:mobile_phone]
			@user.phone = params[:phone]
			@user.address_1 = params[:address_1]
			@user.address_2 = params[:address_2]
			@user.city = params[:city]
			@user.state = params[:state]
			@user.country = params[:country]
			@user.zip = params[:zip]
			@user.save
		else
			render status: 403
		end
	end

	def show_sub_expiry
		if params[:sub_serial].present? && params[:sub_serial].to_i != 0
			device = Roku.find(params[:sub_serial])
			@expiry = device.expiry
		else
			user = User.find(params[:user_id])
			@expiry = user.expiry
		end
	end

	def extend_user_subscription
		if current_admin.authorized_to?('manage_user')
			if params[:sub_serial].present? && params[:sub_serial].to_i != 0
				device = Device.find(params[:sub_serial])
				begin
					if params[:period] == 'days'
						length = params[:length].to_i.days
					elsif params[:period] == 'months'
						length = params[:length].to_i.months
					elsif params[:period] == 'years'
						length = params[:length].to_i.years
					end

					if device.expiry.nil? || device.expiry < Date.today
						device.expiry = Date.today + length
					else
						device.expiry += length
					end

					if device.save
						@user = User.find(device.user_id)
						@success = true
						@message = length
						@expiry = device.expiry
						@type = 'device'
					else
						@success = false
						@message = "Errors: <br/> #{device.errors.full_messages.join("<br/>")}"
					end
				rescue
					@success = false
					@message = 'Not a valid input'
				end
			elsif params[:sub_serial].to_i == 0
				@user = User.find(params[:user_id])
				if params[:period] == 'days'
					length = params[:length].to_i.days
				elsif params[:period] == 'months'
					length = params[:length].to_i.months
				elsif params[:period] == 'years'
					length = params[:length].to_i.years
				end

				if @user.expiry.nil? || @user.expiry < Date.today
					@user.expiry = Date.today + length
				else
					@user.expiry += length
				end

				if @user.save
					@success = true
					@message = length
					@expiry = @user.expiry
					@type = 'user'
				else
					@success = false
					@message = "Errors: <br/> #{user.errors.full_messages.join("<br/>")}"
				end
			else
				@success = false
				@message = 'You must choose a Roku to change'
			end
		else
			render status: 403
		end
	end

	def reset_user_password
		user = User.find(params[:id])
		user.send_reset_password_instructions
	end

	def manual_reset_user_password
		@user = User.find(params[:id])
		@user.password = params[:password]
		@user.save
	end

	def reset_rep_password
		rep = SalesRepresentative.find(params[:id])
		rep.send_reset_password_instructions
	end

	def manual_reset_rep_password
		@rep = SalesRepresentative.find(params[:id])
		@rep.password = params[:password]
		@rep.save
	end

	def register_device
		if current_admin.authorized_to?('manage_user')
			@user = User.find(params[:user_id])
			@device = Roku.new
			@device.serial = params[:serial].upcase
			if @device.serial.include?('O')
				@device.serial = @device.serial.gsub!('O','0')
			end
			@device.name = params[:name]
			@device.user_id = @user.id
			@device.adult = params[:adult]
			if @device.save
				if Rails.env.development?
					path = "#{Rails.root}/serials/#{@device.serial}"
				elsif Rails.env.production?
					path = "/tmp/serials/#{@device.serial}"
				end

				serial_file = File.open(path,'w+')
				@device.serial_file = serial_file
				@device.save
				update = AdminActivity.create(admin_id: current_admin.id, data: YAML.dump({type: 'Device Registration', message: "#{current_admin.name} registered a device.", user_id: @user.id, device_id: @device.id}))
			end
		end
	end

	def unlink_device
		if current_admin.authorized_to?('manage_user')
			@device = Device.find(params[:id])
			@id = @device.id
			@user_id = @device.user_id
			@device.destroy
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

	def show_existing_grids
		@grids = Grid.where(class_type: params[:class_type]).order(name: :asc)
		@grid_options = [['Choose a Grid',nil]]

		@grids.each do |grid|
			@grid_options.push([grid.name, grid.id])
		end
	end

	def show_all_grids
		@grids = Grid.all.order(name: :asc)
		@grid_options = [['Choose a Parent Grid (Optional)',nil]]

		@grids.each do |grid|
			@grid_options.push([grid.name, grid.id])
		end
	end

	def home_grid
		require 'will_paginate/array'
		if current_admin.authorized_to?('update_videos')
			if params[:search].present? || params[:adult].present? || params[:content_type].present?
				@test = 'Search'
				if params[:search].present? && params[:adult].present? && params[:content_type].present?
					@test += ' All 3'
					@grids = Grid.search(params[:search], where: {adult: params[:adult], class_type: params[:content_type], home_page: true})
					array = Array.new
					@grids.each do |grid|
						array.push(grid)
					end
					@grids = array.paginate(page: params[:page], per_page: 10)

				elsif params[:search].present? && params[:adult].present?
					@test += ' Search + Adult'
					@grids = Grid.search(params[:search], where: {adult: params[:adult], home_page: true})
					array = Array.new
					@grids.each do |grid|
						array.push(grid)
					end
					@grids = array.paginate(page: params[:page], per_page: 10)

				elsif params[:search].present? && params[:content_type].present?
					@test += ' Search + Content'
					@grids = Grid.search(params[:search], where: {class_type: params[:content_type], home_page: true})
					array = Array.new
					@grids.each do |grid|
						array.push(grid)
					end
					@grids = array.paginate(page: params[:page], per_page: 10)

				elsif params[:search].present?
					@grids = Grid.search(params[:search], where: {home_page: true})
					array = Array.new
					@grids.each do |grid|
						array.push(grid)
					end
					@grids = array.paginate(page: params[:page], per_page: 10)
				else
					@test += ' Adult or Content'
					hash = Hash.new
					if params[:adult].present?
						hash[:adult] = params[:adult]
					end
					if params[:content_type].present?
						hash[:content_type] = params[:content_type]
					end
					hash[:home_page] = true
					@grids = Grid.where(hash).order(weight: :desc)
					@grids = @grids.paginate(page: params[:page], per_page: 10)
				end
			else
				@test = 'No Search'
				@grids = Grid.where(home_page: true).order(weight: :desc)
				@grids = @grids.paginate(page: params[:page], per_page: 10)
			end
		else
			flash[:error] = 'You are not authorized to view that'
		end
	end
	def all_grids
		if current_admin.authorized_to?('update_videos')
			@grids = Grid.all.order(weight: :desc)
		else
			flash[:error] = 'You are not authorized to view that'
		end
	end
	def view_grid
		@grid = Grid.find(params[:id])
	end
	def update_grid
		@grid = Grid.find(params[:id])
		@grid.name = params[:name]
		old_type = @grid.class_type
		@grid.class_type = params[:class_type]
		@grid.home_page = params[:home_page]
		@grid.title_bar = params[:title_bar]
		@grid.adult = params[:adult]
		@grid.free = params[:free]
		@grid.sort = params[:sort]
		@grid.weight = params[:weight]
		@grid.grid_id = params[:grid_id]
		if @grid.save
			if old_type != @grid.class_type
				if old_type == 'Channel'
					items = Channel.where(grid_id: @grid.id)
				elsif old_type == 'Movie'
					items = Movie.where(grid_id: @grid.id)
				elsif old_type == 'Show'
					items = Show.where(grid_id: @grid.id)
				end

				items.each do |item|
					item.grid_id = nil
					item.save
				end
			end
		end
	end
	def update_grid_image
		@grid = Grid.find(params[:id])
		@grid.image = params[:image]
		@grid.save
	end

	def delete_grid
		@grid = Grid.find(params[:id])
		if params[:redirect] == 'false'
			@redirect == false
			@id = @grid.id
		else
			@redirect = true
		end
		@grid.destroy
	end

	def create_grid
		@grid = Grid.new
		@grid.name = params[:name]
		@grid.class_type = params[:class_type]
		@grid.home_page = params[:home_page]
		@grid.title_bar = params[:title_bar]
		@grid.adult = params[:adult]
		@grid.free = params[:free]
		@grid.sort = params[:sort]
		@grid.weight = params[:weight]
		@grid.save
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
			@withdrawals = Withdrawal.where(sales_rep_id: @rep.id).order(created_at: :asc)
			@users = User.where(rep_id: @rep.id)
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
			@notifs = AdminNotification.where(admin_id: current_admin.id, notif_type: 'ticket').order(created_at: :desc)
		else
			flash[:error] = 'You are not allowed to view that.'
			redirect_to '/admins' and return
		end
	end

	def new_tickets
		search_hash = Hash.new
		search_hash[:status] = 'Pending'
		if params[:search].present? || params[:category].present? || params[:priority].present?
			@cases = Array.new
			if params[:search].present?
				begin
					ticket_number = Integer(params[:search])
					@cases = SupportCase.where(id: ticket_number)
				rescue => e
					users = User.all
					reps = SalesRepresentative.all
					if params[:category].present?
						search_hash[:category] = params[:category]
					end
					if params[:priority].present?
						search_hash[:priority] = params[:priority]
					end

					users.each do |user|
						if user.matches?(params[:search])
							search_hash[:user_id] = user.id
							user_cases = SupportCase.where(search_hash)
							user_cases.each do |user_case|
								@cases.push(user_case)
							end
						end
					end
					search_hash = search_hash.except(:user_id)

					reps.each do |rep|
						if rep.matches?(params[:search])
							search_hash[:sales_representative_id] = rep.id
							rep_cases = SupportCase.where(search_hash)
							rep_cases.each do |rep_case|
								@cases.push(rep_case)
							end
						end
					end
				end
			else
				if params[:category].present?
					search_hash[:category] = params[:category]
				end
				if params[:priority].present?
					search_hash[:priority] = params[:priority]
				end

				cases = SupportCase.where(search_hash)
				cases.each do |search_case|
					@cases.push(search_case)
				end
			end
		else
			@cases = SupportCase.where(search_hash)
		end
	end

	def open_tickets
		search_hash = Hash.new
		search_hash[:status] = 'Open'
		if params[:search].present? || params[:category].present? || params[:priority].present?
			@cases = Array.new
			if params[:search].present?
				begin
					ticket_number = Integer(params[:search])
					@cases = SupportCase.where(id: ticket_number)
				rescue => e
					users = User.all
					reps = SalesRepresentative.all
					if params[:category].present?
						search_hash[:category] = params[:category]
					end
					if params[:priority].present?
						search_hash[:priority] = params[:priority]
					end

					users.each do |user|
						if user.matches?(params[:search])
							search_hash[:user_id] = user.id
							user_cases = SupportCase.where(search_hash)
							user_cases.each do |user_case|
								@cases.push(user_case)
							end
						end
					end
					search_hash = search_hash.except(:user_id)

					reps.each do |rep|
						if rep.matches?(params[:search])
							search_hash[:sales_representative_id] = rep.id
							rep_cases = SupportCase.where(search_hash)
							rep_cases.each do |rep_case|
								@cases.push(rep_case)
							end
						end
					end
				end
			else
				if params[:category].present?
					search_hash[:category] = params[:category]
				end
				if params[:priority].present?
					search_hash[:priority] = params[:priority]
				end

				cases = SupportCase.where(search_hash)
				cases.each do |search_case|
					@cases.push(search_case)
				end
			end
		else
			@cases = SupportCase.where(search_hash)
		end
	end

	def priority_tickets
		search_hash = Hash.new
		search_hash[:status] = 'Open'
		search_hash[:high_priority] = true
		if params[:search].present? || params[:category].present? || params[:priority].present?
			@cases = Array.new
			if params[:search].present?
				begin
					ticket_number = Integer(params[:search])
					@cases = SupportCase.where(id: ticket_number)
				rescue => e
					users = User.all
					reps = SalesRepresentative.all
					if params[:category].present?
						search_hash[:category] = params[:category]
					end
					if params[:priority].present?
						search_hash[:priority] = params[:priority]
					end

					users.each do |user|
						if user.matches?(params[:search])
							search_hash[:user_id] = user.id
							user_cases = SupportCase.where(search_hash)
							user_cases.each do |user_case|
								@cases.push(user_case)
							end
						end
					end
					search_hash = search_hash.except(:user_id)

					reps.each do |rep|
						if rep.matches?(params[:search])
							search_hash[:sales_representative_id] = rep.id
							rep_cases = SupportCase.where(search_hash)
							rep_cases.each do |rep_case|
								@cases.push(rep_case)
							end
						end
					end
				end
			else
				if params[:category].present?
					search_hash[:category] = params[:category]
				end
				if params[:priority].present?
					search_hash[:priority] = params[:priority]
				end

				cases = SupportCase.where(search_hash)
				cases.each do |search_case|
					@cases.push(search_case)
				end
			end
		else
			@cases = SupportCase.where(search_hash)
		end
	end

	def closed_tickets
		search_hash = Hash.new
		search_hash[:status] = 'Closed'
		if params[:search].present? || params[:category].present? || params[:priority].present?
			@cases = Array.new
			if params[:search].present?
				begin
					ticket_number = Integer(params[:search])
					@cases = SupportCase.where(id: ticket_number)
				rescue => e
					users = User.all
					reps = SalesRepresentative.all
					if params[:category].present?
						search_hash[:category] = params[:category]
					end
					if params[:priority].present?
						search_hash[:priority] = params[:priority]
					end

					users.each do |user|
						if user.matches?(params[:search])
							search_hash[:user_id] = user.id
							user_cases = SupportCase.where(search_hash)
							user_cases.each do |user_case|
								@cases.push(user_case)
							end
						end
					end
					search_hash = search_hash.except(:user_id)

					reps.each do |rep|
						if rep.matches?(params[:search])
							search_hash[:sales_representative_id] = rep.id
							rep_cases = SupportCase.where(search_hash)
							rep_cases.each do |rep_case|
								@cases.push(rep_case)
							end
						end
					end
				end
			else
				if params[:category].present?
					search_hash[:category] = params[:category]
				end
				if params[:priority].present?
					search_hash[:priority] = params[:priority]
				end

				cases = SupportCase.where(search_hash)
				cases.each do |search_case|
					@cases.push(search_case)
				end
			end
		else
			@cases = SupportCase.where(search_hash)
		end
	end



	def archived_tickets
		search_hash = Hash.new
		search_hash[:status] = 'Archived'
		if params[:search].present? || params[:category].present? || params[:priority].present?
			@cases = Array.new
			if params[:search].present?
				begin
					ticket_number = Integer(params[:search])
					@cases = SupportCase.where(id: ticket_number)
				rescue => e
					users = User.all
					reps = SalesRepresentative.all
					if params[:category].present?
						search_hash[:category] = params[:category]
					end
					if params[:priority].present?
						search_hash[:priority] = params[:priority]
					end

					users.each do |user|
						if user.matches?(params[:search])
							search_hash[:user_id] = user.id
							user_cases = SupportCase.where(search_hash)
							user_cases.each do |user_case|
								@cases.push(user_case)
							end
						end
					end
					search_hash = search_hash.except(:user_id)

					reps.each do |rep|
						if rep.matches?(params[:search])
							search_hash[:sales_representative_id] = rep.id
							rep_cases = SupportCase.where(search_hash)
							rep_cases.each do |rep_case|
								@cases.push(rep_case)
							end
						end
					end
				end
			else
				if params[:category].present?
					search_hash[:category] = params[:category]
				end
				if params[:priority].present?
					search_hash[:priority] = params[:priority]
				end

				cases = SupportCase.where(search_hash)
				cases.each do |search_case|
					@cases.push(search_case)
				end
			end
		else
			@cases = SupportCase.where(search_hash)
		end
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
			if @device.type == 'Roku'
				@device.serial = params[:device_serial].upcase
				if @device.serial.include?('O')
					@device.serial = @device.serial.gsub!('O','0')
				end
				@device.name = params[:device_name]
				@device.adult = params[:device_adult]
				if @device.save
					if Rails.env.development?
						path = "#{Rails.root}/serials/#{@device.serial}"
					elsif Rails.env.production?
						path = "/tmp/serials/#{@device.serial}"
					end

					serial_file = File.open(path,'w+')
					@device.serial_file = serial_file
					@device.save
				end
			else
				@device.name = params[:device_name]
				@device.adult = params[:device_adult]
				@device.save
			end
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
			@withdrawals = Withdrawal.all
		else
			flash[:error] = 'You are not authorized to view that.'
			redirect_to '/admins'
		end
	end

	def view_request
		if current_admin.authorized_to?('authorize_withdrawal')
			@withdrawal = Withdrawal.find(params[:id])
			if @withdrawal.status == 'Pending'
				@withdrawal.status = 'Reviewed'
				@withdrawal.save
			end
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
			@withdrawal.note = params[:note]
			if @withdrawal.save
				flash[:success] = 'Withdrawal Approved! '+@withdrawal.status
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
			flash[:success] = 'Withdrawal fail!'
			render status: 403
		end
	end

	def deny_request
		if current_admin.authorized_to?('authorize_withdrawal')
			@withdrawal = Withdrawal.find(params[:id])
			@withdrawal.status = 'Denied'
			@withdrawal.approved = DateTime.now
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
			@role.name = params[:name]
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
			@role.save
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



	def general_settings
		unless current_admin.authorized_to?('edit_general_settings')
			flash[:error] = 'You are not allowed to view that.'
			redirect_to '/admins'
		end
	end

	def edit_payouts
		unless current_admin.authorized_to?('edit_general_settings')
			flash[:error] = 'You are not allowed to view that.'
			redirect_to '/admins'
		end
		@methods = Setting.where(name: 'Payout Methods').first.data
	end

	def update_payout_methods
		unless current_admin.authorized_to?('edit_general_settings')
			render status: 403
		end
		@methods = Setting.where(name: 'Payout Methods').first
		@methods.data = params[:methods]
		if @methods.save
			flash[:success] = 'Payout Methods updated'
		else
			flash[:error] = 'An error occurred while performing the update'
		end
		redirect_to edit_payouts_path
	end

	def edit_contact_email
		unless current_admin.authorized_to?('edit_general_settings')
			flash[:error] = 'You are not allowed to view that.'
			redirect_to '/admins'
		end
		@email = Setting.where(name: 'Contact Email').first.data
	end

	def update_contact_email
		unless current_admin.authorized_to?('edit_general_settings')
			render status: 403
		end
		@email = Setting.where(name: 'Contact Email').first
		@email.data = params[:email]
		if @email.save
			flash[:success] = 'Contact Email updated'
		else
			flash[:error] = 'An error occurred while performing the update'
		end
		redirect_to edit_payouts_path
	end

	def edit_footer_content
		@data = YAML.load(Setting.where(name: 'Footer Content').first.data)
	end

	def update_footer_content
		setting = Setting.where(name: 'Footer Content').first
		@data = YAML.load(setting.data)

		@data[0][:name] = params[:name_0]
		@data[0][:html] = params[:html_0]

		@data[1][:name] = params[:name_1]
		@data[1][:html] = params[:html_1]

		@data[2][:name] = params[:name_2]
		@data[2][:html] = params[:html_2]

		@data[3][:name] = params[:name_3]
		@data[3][:html] = params[:html_3]

		@data[4][:name] = params[:name_4]
		@data[4][:html] = params[:html_4]

		@data[5][:name] = params[:name_5]
		@data[5][:html] = params[:html_5]

		@data[6] = params[:bottom_content]

		setting.data = YAML.dump(@data)
		setting.save
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

	def orders
		#order ratio/total today/this month
		today = Date.today
		last_month_day = today.beginning_of_month.beginning_of_day - 1.day
		i = 0
		@today_tx = Transaction.where(created_at: today.beginning_of_day..today.end_of_day).count
		@this_month_tx = Transaction.where(created_at: today.beginning_of_month.beginning_of_day..today.end_of_month.end_of_day).count
		@last_month_tx = Transaction.where(created_at: last_month_day.beginning_of_month.beginning_of_day..last_month_day.end_of_month.end_of_day).count

		ratio = 0
		days_this_month = (today.end_of_month).day
		days_this_month_so_far = today.day
		days_last_month = (today.beginning_of_month.beginning_of_day - 1.day).day


		this_month_per_day = (@this_month_tx.to_f/days_this_month.to_f)
		last_month_per_day = (@last_month_tx.to_f/days_last_month.to_f)

		unless last_month_per_day == 0
			@ratio = ((this_month_per_day/last_month_per_day) - 1) * 100
		else
			@ratio = 'N/A'
		end

		# plan popularity
		@plans = Hash.new
		@plans[:plan_1] = Plan.find(1)
		@plans[:plan_2] = Plan.find(2)
		@plans[:plan_3] = Plan.find(3)
		@plans[:plan_4] = Plan.find(4)

		@plan_totals = Hash.new
		@plan_totals[:plan_1] = Transaction.where(plan_id: 1).count
		@plan_totals[:plan_2] = Transaction.where(plan_id: 2).count
		@plan_totals[:plan_3] = Transaction.where(plan_id: 3).count
		@plan_totals[:plan_4] = Transaction.where(plan_id: 4).count

		@max = @plan_totals.max_by{|k,v| v}
		@max_plan = @plans[@max[0]]
	end

	def load_devices
		@devices = Roku.where(user_id: params[:user_id])
		@options = [['Choose a Roku',nil],['Web/Tablets/Mobile',0]]
		@devices.each do |device|
			if device.name.present?
				@options.push(["#{device.nickname(false)} - #{device.serial}", device.id])
			else
				@options.push(["#{device.serial}", device.id])
			end
		end
	end

	def create_transaction
		if params[:user_id].present? && params[:device_id].present?
			@user = User.find(params[:user_id])
			@plan = Plan.find(params[:plan_id])
			if params[:device_id].to_i == 0
				@device = nil
			else
				@device = Roku.find(params[:device_id])
			end

			total = @plan.price - @user.balance

			if total > 0 && params[:payment_type].present?
				if params[:payment_type] == 'Credit Card'
					# Send requests to the gateway's test servers
					ActiveMerchant::Billing::Base.mode = :test

					# Create a new credit card object

					names = params[:card_name].split(' ', 2)
					credit_card = ActiveMerchant::Billing::CreditCard.new(
						:number     => params[:card_number],
						:month      => params[:card_month],
						:year       => params[:card_year],
						:first_name => names[0],
						:last_name  => names[1],
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
							@user.balance = 0
							unless @device.nil?
								if @device.expiry.nil? || @device.expiry < Date.today
									@device.expiry = Date.today + @plan.months.months
								else
									@device.expiry += @plan.months.months
								end
							else
								if @user.expiry.nil? || @user.expiry < Date.today
									@user.expiry = Date.today + @plan.months.months
								else
									@user.expiry += @plan.months.months
								end
							end
							@user.save
							@device.save
							transaction = Transaction.new
							transaction.user_id = @user.id
							unless @device.nil?
								transaction.roku_id = @device.id
							end
							transaction.payment_type = 'Credit Card'
							transaction.paypal_id = response.params['transaction_id']
							transaction.status = 'Paid'
							transaction.customer_paid = DateTime.now
							transaction.product_details = YAML.dump({name: @plan.name, duration: @plan.months, price: @plan.price})
							transaction.plan_id = @plan.id
							transaction.balance_used = @plan.price - total
							transaction.save
							@tx_id = transaction.id
							OrderNotification.create(transaction_id: @transaction.id,message: "Order \##{transaction.id} has been created and paid.", link: true)
							TransactionalMailer.order_paid(transaction, @user).deliver
						else
							@tx_errors = true
							@tx_error = response.message
						end
					else
						@tx_errors = true
						@tx_error = 'This card is not valid'
					end
				elsif params[:payment_type].present?
					transaction = Transaction.new
					transaction.user_id = @user.id
					transaction.payment_type = params[:payment_type]
					transaction.status = 'Pending'
					transaction.product_details = YAML.dump({name: @plan.name, duration: @plan.months, price: @plan.price})
					transaction.plan_id = @plan.id
					transaction.balance_used = @plan.price - total
					transaction.roku_id = @device.id
					transaction.save
					OrderNotification.create(transaction_id: transaction.id,message: "Order \##{transaction.id} has been created.", link: true)
					@tx_id = transaction.id
					TransactionalMailer.order_created(transaction, @user).deliver
					@tx_errors = false
				else
					@tx_errors = true
					@tx_error = 'You must choose a payment type.'
				end
			elsif total <= 0
				@user.balance = @user.balance - @plan.price
				@user.save
				if @device.expiry.nil? || @device.expiry < Date.today
					@device.expiry = Date.today + @plan.months.months
				else
					@device.expiry += @plan.months.months
				end
				@device.save
				transaction = Transaction.new
				transaction.user_id = @user.id
				transaction.payment_type = 'Previous Balance'
				transaction.status = 'Paid'
				transaction.balance_used = @plan.price
				transaction.product_details = YAML.dump({name: @plan.name, duration: @plan.months, price: @plan.price})
				transaction.plan_id = @plan.id
				transaction.save
				OrderNotification.create(transaction_id: @transaction.id,message: "Order \##{transaction.id} has been created and paid.", link: true)
				@tx_id = transaction.id
				TransactionalMailer.order_paid(transaction, @user).deliver
			end
		else
			if params[:user_id].present? == false
				@user_error = true
			end
			if params[:user_id].present? && params[:device_id].present? == false
				@device_error = true
			end
		end
	end

	def pending_transactions
		search_hash = Hash.new
		search_hash[:status] = 'Pending'
		if params[:search].present? || params[:payment_type].present?
			@transactions = Array.new
			if params[:search].present?
				begin
					order_number = Integer(params[:search])
					@transactions = Transaction.where(id: order_number)
				rescue => e
					users = User.all
					if params[:payment_type].present?
						search_hash[:payment_type] = params[:payment_type]
					end

					users.each do |user|
						if user.matches?(params[:search])
							search_hash[:user_id] = user.id
							txs = Transaction.where(search_hash)
							txs.each do |tx|
								@transactions.push(tx)
							end
						end
					end
				end
			else
				if params[:payment_type].present?
					search_hash[:payment_type] = params[:payment_type]
				end

				txs = Transaction.where(search_hash)
				txs.each do |tx|
					@transactions.push(tx)
				end
			end
		else
			@transactions = Transaction.where(status: 'Pending')
		end
	end

	def paid_transactions
		search_hash = Hash.new
		search_hash[:status] = 'Paid'
		if params[:search].present? || params[:payment_type].present?
			@transactions = Array.new
			if params[:search].present?
				begin
					order_number = Integer(params[:search])
					@transactions = Transaction.where(id: order_number)
				rescue => e
					users = User.all
					if params[:payment_type].present?
						search_hash[:payment_type] = params[:payment_type]
					end

					users.each do |user|
						if user.matches?(params[:search])
							search_hash[:user_id] = user.id
							txs = Transaction.where(search_hash)
							txs.each do |tx|
								@transactions.push(tx)
							end
						end
					end
				end
			else
				if params[:payment_type].present?
					search_hash[:payment_type] = params[:payment_type]
				end

				txs = Transaction.where(search_hash)
				txs.each do |tx|
					@transactions.push(tx)
				end
			end
		else
			@transactions = Transaction.where(status: 'Paid')
		end
	end

	def refunded_transactions
		search_hash = Hash.new
		search_hash[:status] = 'Refunded'
		if params[:search].present? || params[:payment_type].present?
			@transactions = Array.new
			if params[:search].present?
				begin
					order_number = Integer(params[:search])
					@transactions = Transaction.where(id: order_number)
				rescue => e
					users = User.all
					if params[:payment_type].present?
						search_hash[:payment_type] = params[:payment_type]
					end

					users.each do |user|
						if user.matches?(params[:search])
							search_hash[:user_id] = user.id
							txs = Transaction.where(search_hash)
							txs.each do |tx|
								@transactions.push(tx)
							end
						end
					end
				end
			else
				if params[:payment_type].present?
					search_hash[:payment_type] = params[:payment_type]
				end

				txs = Transaction.where(search_hash)
				txs.each do |tx|
					@transactions.push(tx)
				end
			end
		else
			@transactions = Transaction.where(status: 'Refunded')
		end
	end

	def cancelled_transactions
		search_hash = Hash.new
		search_hash[:status] = 'Cancelled'
		if params[:search].present? || params[:payment_type].present?
			@transactions = Array.new
			if params[:search].present?
				begin
					order_number = Integer(params[:search])
					@transactions = Transaction.where(id: order_number)
				rescue => e
					users = User.all
					if params[:payment_type].present?
						search_hash[:payment_type] = params[:payment_type]
					end

					users.each do |user|
						if user.matches?(params[:search])
							search_hash[:user_id] = user.id
							txs = Transaction.where(search_hash)
							txs.each do |tx|
								@transactions.push(tx)
							end
						end
					end
				end
			else
				if params[:payment_type].present?
					search_hash[:payment_type] = params[:payment_type]
				end

				txs = Transaction.where(search_hash)
				txs.each do |tx|
					@transactions.push(tx)
				end
			end
		else
			@transactions = Transaction.where(status: 'Cancelled')
		end
	end

	def upload_customers
		upload = ClientMigration.new
		upload.file = params[:file]
		upload.status = false
		upload.save
		Resque.enqueue(CustomerUploader, upload.id)
		redirect_to '/admins'
	end

	private

	def file_type(file)
		case File.extname(file.original_filename)
		when '.csv' then Roo::Csv.new(file.path, nil, :ignore)
		when '.xls' then Roo::Excel.new(file.path, nil, :ignore)
		when '.xlsx' then Roo::Excelx.new(file.path, nil, :ignore)
		else raise "Unknown file type: #{file.original_filename}"
		end
	end
end
