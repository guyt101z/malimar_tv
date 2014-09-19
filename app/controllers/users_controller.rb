class UsersController < ApplicationController
	def send_contact_message
		if params[:message].present? && params[:first_name].present? && params[:last_name].present? && params[:email].present?
			TransactionalMailer.contact_us_message(params[:first_name], params[:last_name], params[:email], params[:message]).deliver
			@success = true
		else
			@success = false
		end
	end

	def create_new
		@user = User.new(params)
		code = SecureRandom.hex(5).upcase
		until User.where(refer_code: code).count < 1
			code = SecureRandom.hex(5).upcase
		end
		@user.refer_code = code
		@user.balance = 0
		if @user.save
			@success = true
			sign_in(@user)
			TransactionalMailer.self_sign_up(@user).deliver

			begin
				if @user.mailchimp == true
					mailchimp = Mailchimp::API.new(YAML.load(Setting.where(name: 'MailChimp Credentials').first.data)[:api_key])
					mailchimp.lists.subscribe(YAML.load(Setting.where(name: 'MailChimp Credentials').first.data)[:list_id], {'EMAIL' => @user.email})
				end
			rescue

			end

			Resque.enqueue(AdminNotifier, 0, 'system', "#{@user.name} has joined.", search_users_path(id: @user.id))
		else
			@success = false
		end
	end

	def view_plan
		@plan = Plan.find(params[:id])
		@balance = current_user.balance
		if params[:roku_id].present?
			@device = Roku.find(params[:roku_id])
		else
			@device = Device.new
		end
	end

	def settings
		mailchimp = Mailchimp::API.new(YAML.load(Setting.where(name: 'MailChimp Credentials').first.data)[:api_key])
		sub_list = mailchimp.lists.members(YAML.load(Setting.where(name: 'MailChimp Credentials').first.data)[:list_id])['data']

		@subscribed = false

		sub_list.each do |user_sub|
			if user_sub['email'] == current_user.email
				@subscribed = true
			end
		end
	end

	def subscribe_to_mailchimp
		mailchimp = Mailchimp::API.new(YAML.load(Setting.where(name: 'MailChimp Credentials').first.data)[:api_key])
		mailchimp.lists.subscribe(YAML.load(Setting.where(name: 'MailChimp Credentials').first.data)[:list_id], {'email' => current_user.email})

		sub_list = mailchimp.lists.members(YAML.load(Setting.where(name: 'MailChimp Credentials').first.data)[:list_id])['data']
	end

	def unsubscribe_from_mailchimp
		mailchimp = Mailchimp::API.new(YAML.load(Setting.where(name: 'MailChimp Credentials').first.data)[:api_key])
		mailchimp.lists.unsubscribe(YAML.load(Setting.where(name: 'MailChimp Credentials').first.data)[:list_id], {'email' => current_user.email})

		sub_list = mailchimp.lists.members(YAML.load(Setting.where(name: 'MailChimp Credentials').first.data)[:list_id])['data']

		@subscribed = false

		sub_list.each do |user_sub|
			if user_sub['email'] == current_user.email
				@subscribed = true
			end
		end
	end

	def reset_password
		user = User.authenticate(current_user.email, params[:current])
		if user.nil?
			@error_type = 'Current'
			@error = 'Old password is incorrect'
		else
			if params[:new] == params[:new_confirmation]
				user.password = params[:new]
				if user.save
					@error = nil
					sign_in(user, bypass: true)
				else
					@error_type = 'Length'
					@error = 'Password not long enough'
				end
			else
				@error_type = 'Confirmation'
				@error = 'New password and confirmation do not match'
			end
		end
	end

	def subscribe
		@one_month = Plan.find(1)
		@three_month = Plan.find(2)
		@six_month = Plan.find(3)
		@twelve_month = Plan.find(4)
	end

	def subscribe_newsletter_footer
		begin
			if params[:sub_email].present?
				mailchimp = Mailchimp::API.new(YAML.load(Setting.where(name: 'MailChimp Credentials').first.data)[:api_key])
				mailchimp.lists.subscribe(YAML.load(Setting.where(name: 'MailChimp Credentials').first.data)[:list_id], {'email' => params[:sub_email]})
			else
				@error = "You must enter an email address"
			end
		rescue
			@error = "Sorry, an issue occured subscribing your email"
		end
	end

	def add_subscription
		@plan = Plan.find(params[:plan_id])

		if params[:new_serial].present?
			@device = Roku.new
			@device.user_id = current_user.id
			@device.serial = params[:new_serial].upcase
			if @device.serial.include?('O')
				@device.serial = @device.serial.gsub!('O','0')
			end

			if @device.valid?
				@device_errors = false
				@device.type = 'Roku'
				length = Setting.where(name: 'Roku Free Trial Length').first.data
				@device.start_date = Date.today
				@device.expiry = Date.today + length.to_i.days
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
				end
			else
				@device_errors = true
				@device_error = 'Serial '+ @device.errors[:serial].join(", ")
			end
		elsif params[:serial].present? && params[:serial].to_i != 0
			@device = Device.find(params[:serial])
			@device_errors = false
		elsif params[:serial].present? && params[:serial].to_i == 0
			@device = nil
			@device_errors = false
		else
			@device = nil
			@device_errors = true
			@device_error = 'You must register a Roku or select an existing device'
		end

		if @device_errors == false
			if params[:refer_code].present?
				@test1 = 'Test'
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
			if current_user.balance.nil?
				total = @plan.price
			else
				total = @plan.price - current_user.balance
			end

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





						response = gateway.purchase((total*100).to_i, credit_card, ip: '104.131.205.107')

						if response.success?
					    	transaction = Transaction.new
							transaction.user_id = user.id
							transaction.payment_type = 'Credit Card'
							transaction.paypal_id = response.params['transaction_id']
							transaction.status = 'Paid'
							transaction.customer_paid = DateTime.now
							unless @device.nil?
								transaction.roku_id = @device.id
							end
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
							transaction.plan_id = @plan.id
							unless @device.nil?
								transaction.roku_id = @device.id
							end

							if @device.present?
								if @device.expiry.nil? || @device.expiry < Date.today
									@device.expiry = Date.today + @plan.months.months
								else
									@device.expiry += @plan.months.months
								end
								@device.save
							else
								if current_user.expiry.nil? || current_user.expiry < Date.today
									@user = current_user
									@user.expiry = Date.today + @plan.months.months
								else
									@user = current_user
									@user.expiry += @plan.months.months
								end
								@user.save
							end

							transaction.balance_used = @plan.price - total
							transaction.save
							@success = true
							flash[:success] = 'Your subscription has been successfully processed.'
							OrderNotification.create(transaction_id: transaction.id,message: "Order \##{transaction.id} has been created and paid.", link: true)
							TransactionalMailer.order_paid(transaction, user).deliver
						else
					    	@payment_errors = true
							@payment_message = response.message
							if params[:new_serial].present?
								@device.destroy
							end
						end
					else
						@payment_errors = true
						@payment_message = 'This credit card is not valid.'
						if params[:new_serial].present?
							@device.destroy
						end
					end
				else
					user = current_user
					user.balance = 0
					user.save
					transaction = Transaction.new
					transaction.user_id = user.id
					transaction.payment_type = params[:payment_type]
					transaction.status = 'Pending'
					unless @device.nil?
						transaction.roku_id = @device.id
					end
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
					transaction.plan_id = @plan.id
					transaction.balance_used = @plan.price - total
					transaction.save
					@success = true
					flash[:success] = 'Your order has been processed. Please send your payment to activate your subscription.'
					OrderNotification.create(transaction_id: transaction.id,message: "Order \##{transaction.id} has been created.", link: true)
					TransactionalMailer.order_created(transaction, user).deliver
				end
			elsif total <= 0
				user = current_user
				user.balance = user.balance - @plan.price
				user.save
				@device.save
				transaction = Transaction.new
				transaction.user_id = user.id
				transaction.payment_type = 'Previous Balance'
				transaction.status = 'Paid'
				transaction.balance_used = @plan.price

				if @device.present?
					if @device.expiry.nil? || @device.expiry < Date.today
						@device.expiry = Date.today + @plan.months.months
					else
						@device.expiry += @plan.months.months
					end
					@device.save
				else
					if current_user.expiry.nil? || current_user.expiry < Date.today
						@user = current_user
						@user.expiry = Date.today + @plan.months.months
					else
						@user = current_user
						@user.expiry += @plan.months.months
					end
					@user.save
				end

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
				transaction.plan_id = @plan.id
				unless @device.nil?
					transaction.roku_id = @device.id
					@device.save
				end
				transaction.save
				OrderNotification.create(transaction_id: transaction.id,message: "Order \##{transaction.id} has been created and paid.", link: true)
			else
				@payment_errors = true
				@payment_message = 'You must select a payment type.'
				if params[:new_serial].present?
					@device.destroy
				end
			end
		end


	end

	def add_note
		if params[:new_note_id].present?
			@note = UserNote.find(params[:new_note_id])
		else
			@note = UserNote.new
		end

		@note.user_id = params[:user_id]
		@note.title = params[:note_title]
		@note.note = params[:note]
		@note.note_colour = params[:color]

		if params[:check_item].present?
			checklist = Array.new
			params[:check_item].each_with_index do |item, i|
				unless item.blank?
					array = Array.new
					array.push(item)
					checklist.push(array)
				end
			end
			params[:check_status].each_with_index do |status, i|
				unless params[:check_item][i].blank?
					checklist[i].push(status)
				end
			end
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

		@note.save
		@note_files = NoteFile.where(note_id: @note.id)
	end

	def update_note
		@note = UserNote.find(params[:note_id])
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

		@note.save
	end

	def add_image_to_existing_note
		@note_image = NoteFile.new
		@note = UserNote.find(params[:note_id_for_image])
		@note_image.note_id = @note.id
		@note_image.file = params[:image]
		@note_image.save
	end

	def add_image_to_note
		@note_image = NoteFile.new
		if params[:note_id_for_image].present?
			@note = UserNote.find(params[:note_id_for_image])
			@note_image.note_id = @note.id
		else
			@note = UserNote.create()
			@note_image.note_id = @note.id
		end
		@note_image.file = params[:image]
		@note_image.save
	end

	def delete_note_file
		file = NoteFile.find(params[:id])
		@id = file.id
		file.destroy
	end

	def delete_note
		@note = UserNote.find(params[:id])
		@note_files = NoteFile.where(note_id: @note.id)
		@id = @note.id
		@note.destroy
		@note_files.destroy_all
	end
	def delete_unsaved_note
		note = UserNote.find(params[:id])
		note_images = NoteFile.where(note_id: params[:id])
		note.destroy
		note_images.destroy_all
	end

	def account
	end

	def new_ticket
		@transactions = Transaction.where(user_id: current_user)
		@transactions_array = [['Choose a transaction', nil]]

	end

	def view_device
		@device = Device.find(params[:id])
	end

	def update_device
		@device = Device.find(params[:id])
		@device.name = params[:name]
		@device.save
	end

	def update_roku
		@device = Device.find(params[:id])
		if @device.type == 'Roku'
			@device.serial = params[:serial].upcase
			if @device.serial.include?('O')
				@device.serial = @device.serial.gsub!('O','0')
			end
		end
		@device.name = params[:name]
		@device.save
	end

	def unlink_device
		@device = Device.find(params[:id])
		@id = @device.id
		@device.destroy
	end

	def register_new_device
		if params[:serial].present?
			serial = params[:serial].upcase
			if serial.include?('O')
				serial = serial.gsub!('O','0')
			end
			@device = Roku.new
			@device.serial = serial
		else
			@device = nil
		end
		@device.user_id = current_user.id
		length = Setting.where(name: 'Roku Free Trial Length').first.data
		@device.start_date = Date.today
		@device.expiry = Date.today + length.days
		if current_user.max_devices?
			@device.errors.add(:base, 'You have reached the maximum limit for your registered devices.')
		else
			if @device.save
				@success = true
				@device_present = true

				if Rails.env.development?
					path = "#{Rails.root}/serials/#{serial}"
				elsif Rails.env.production?
					path = "/tmp/serials/#{serial}"
				end

				serial_file = File.open(path,'w+')
				@device.serial_file = serial_file
				@device.save
			end
		end
	end

	def update_profile
		@user = current_user
		@user.first_name = params[:first_name]
		@user.last_name = params[:last_name]

		@user.email = params[:email]
		@user.address_1 = params[:address_1]
		@user.address_2 = params[:address_2]
		@user.city = params[:city]
		@user.country = params[:country]
		if params[:country] == 'CA'
			@user.state = params[:province]
		elsif params[:country] == 'US'
			@user.state = params[:state]
		else
			@user.state = params[:state_input]
		end
		@user.zip = params[:zip]


		if params[:phone_1].present?
			phone_1 = params[:phone_1]
			if params[:phone_1].include?(' ')
				phone_1 = phone_1.gsub!(' ','')
			end
			if phone_1.include?('-')
				phone_1 = phone_1.gsub!('-','')
			end
			if phone_1.include?('(')
				phone_1 = phone_1.gsub!('(','')
			end
			if phone_1.include?(')')
				phone_1 = phone_1.gsub!(')','')
			end
			phone_1 = view_context.number_to_phone(phone_1)
		else
			phone_1 = nil
		end
		if params[:phone_2].present?
			phone_2 = params[:phone_2]
			if params[:phone_2].include?(' ')
				phone_2 = phone_2.gsub!(' ','')
			end
			if phone_2.include?('-')
				phone_2 = phone_2.gsub!('-','')
			end
			if phone_2.include?('(')
				phone_2 = phone_2.gsub!('(','')
			end
			if phone_2.include?(')')
				phone_2 = phone_2.gsub!(')','')
			end
			phone_2 = view_context.number_to_phone(phone_2)
		else
			phone_2 = nil
		end
		if params[:phone_3].present?
			phone_3 = params[:phone_3]
			if params[:phone_3].include?(' ')
				phone_3 = phone_3.gsub!(' ','')
			end
			if phone_3.include?('-')
				phone_3 = phone_3.gsub!('-','')
			end
			if phone_3.include?('(')
				phone_3 = phone_3.gsub!('(','')
			end
			if phone_3.include?(')')
				phone_3 = phone_3.gsub!(')','')
			end
			phone_3 = view_context.number_to_phone(phone_3)
		else
			phone_3 = nil
		end

		@user.phone_1 = phone_1
		@user.phone_2 = phone_2
		@user.phone_3 = phone_3
		@user.paperless_billing = params[:paperless_billing]

		if params[:timezone].present?
			@user.timezone = params[:timezone]
		else
			@user.timezone = nil
		end
		@user.save
	end

	def free_trial
		if user_signed_in?
			redirect_to '/account'
		end
	end

	def devices
		@devices = Device.where(user_id: current_user.id)
	end

	def billing
		@transactions = Transaction.where(user_id: current_user.id).order(created_at: :desc)
		@transactions = @transactions.paginate(page: params[:page], per_page: 8)
	end

	def support
		@open_tickets = SupportCase.where(user_id: current_user.id, status: ['Pending','Open']).order(updated_at: :desc)
		@closed_tickets = SupportCase.where(user_id: current_user.id, status: ['Closed','Archived']).order(updated_at: :desc)
	end

	def free_trial_1
		if params[:serial].present?
			@device = Roku.new
		else
			@device = nil
		end
		@device_errors = false

		@user = User.new
		length = Setting.where(name: 'Web Free Trial Length').first.data.to_i
		@user.start_date = Date.today
		@user.expiry = Date.today + length.days
		@user.first_name = params[:first_name]
		@user.last_name = params[:last_name]
		@user.mailchimp = params[:mailchimp]
		@user.email = params[:email]
		@user.address_1 = params[:address_1]
		@user.address_2 = params[:address_2]
		@user.city = params[:city]
		@user.country = params[:country]
		if params[:country] == 'CA'
			@user.state = params[:province]
		elsif params[:country] == 'US'
			@user.state = params[:state]
		else
			@user.state = params[:state_input]
		end
		@user.zip = params[:zip]
		if params[:phone_1].present?
			phone_1 = params[:phone_1]
			if params[:phone_1].include?(' ')
				phone_1 = phone_1.gsub!(' ','')
			end
			if phone_1.include?('-')
				phone_1 = phone_1.gsub!('-','')
			end
			if phone_1.include?('(')
				phone_1 = phone_1.gsub!('(','')
			end
			if phone_1.include?(')')
				phone_1 = phone_1.gsub!(')','')
			end
			phone_1 = view_context.number_to_phone(phone_1)
		else
			phone_1 = nil
		end
		if params[:phone_2].present?
			phone_2 = params[:phone_2]
			if params[:phone_2].include?(' ')
				phone_2 = phone_2.gsub!(' ','')
			end
			if phone_2.include?('-')
				phone_2 = phone_2.gsub!('-','')
			end
			if phone_2.include?('(')
				phone_2 = phone_2.gsub!('(','')
			end
			if phone_2.include?(')')
				phone_2 = phone_2.gsub!(')','')
			end
			phone_2 = view_context.number_to_phone(phone_2)
		else
			phone_2 = nil
		end
		if params[:phone_3].present?
			phone_3 = params[:phone_3]
			if params[:phone_3].include?(' ')
				phone_3 = phone_3.gsub!(' ','')
			end
			if phone_3.include?('-')
				phone_3 = phone_3.gsub!('-','')
			end
			if phone_3.include?('(')
				phone_3 = phone_3.gsub!('(','')
			end
			if phone_3.include?(')')
				phone_3 = phone_3.gsub!(')','')
			end
			phone_3 = view_context.number_to_phone(phone_3)
		else
			phone_3 = nil
		end

		@user.phone_1 = phone_1
		@user.phone_2 = phone_2
		@user.phone_3 = phone_3
		@user.paperless_billing = params[:paperless_billing]
		@user.password = params[:password]
		@user.password_confirmation = params[:password_confirmation]

		code = SecureRandom.hex(5).upcase
		until User.where(refer_code: code).count < 1
			code = SecureRandom.hex(5).upcase
		end
		@user.refer_code = code

		if @user.save
			@user_errors = false
			unless @device.nil?
				@device.user_id = @user.id
				@device.type = 'Roku'
				@device.serial = params[:serial].upcase
				@device.name = params[:nickname]
				length = Setting.where(name: 'Roku Free Trial Length').first.data.to_i
				@device.start_date = Date.today
				@device.expiry = Date.today + length.days
				if @device.serial.include?('O')
					@device.serial = @device.serial.gsub!('O','0')
				end
				@device.name = params[:nickname]
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
					sign_in(@user, bypass: true)
				else
					@device_errors = true
					@device_error = 'Serial ' + @device.errors[:serial].join(', ')
					@user.destroy
				end
				begin
					if @user.mailchimp == true
						mailchimp = Mailchimp::API.new(YAML.load(Setting.where(name: 'MailChimp Credentials').first.data)[:api_key])
						mailchimp.lists.subscribe(YAML.load(Setting.where(name: 'MailChimp Credentials').first.data)[:list_id], {'EMAIL' => @user.email})
					end
				rescue

				end
			else
				@user_errors = false
				sign_in(@user, bypass: true)
			end
		else
			@user_errors = true
		end
	end
end
