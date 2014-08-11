class UsersController < ApplicationController
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
					mailchimp = Mailchimp::API.new(YAML.load(Setting.where(name: 'MailChimp Credentials').first)[:api_key])
					mailchimp.lists.subscribe(YAML.load(Setting.where(name: 'MailChimp Credentials').first)[:list_id], {'EMAIL' => @user.email})
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
	end

	def subscribe
		@one_month = Plan.find(1)
		@three_month = Plan.find(2)
		@six_month = Plan.find(3)
		@twelve_month = Plan.find(4)
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
							TransactionalMailer.order_paid(transaction, user).deliver
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
					transaction.user_id = user.id
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
					@success = true
					flash[:success] = 'Your order has been processed. Please send your payment to activate your subscription.'
					TransactionalMailer.order_created(transaction, user).deliver
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

	def start_free_trial
		user = current_user
		unless user.expiry.nil?
			flash[:error] = 'You are not qualified for the free trial.'
		else
			length = Setting.where(name: 'Free Trial Length').first.data
			user.expiry = Date.today + length.to_i.days
			user.save
			transaction = Transaction.new
			transaction.user_id = user.id
			transaction.status = 'Paid'
			transaction.product_details = YAML.dump({name: 'Free Trial', price: 0, duration: length})
			transaction.payment_type = 'N/A'
			transaction.save
			flash[:success] = 'Your free trial has started. It will end on '+user.expiry.strftime('%B %-d, %Y')+'.'
		end
		redirect_to '/account'
	end

	def add_note
		if params[:new_note_id].present?
			@note = UserNote.find(params[:new_note_id])
		else
			@note = UserNote.new
		end

		@note.user_id = params[:user_id]
		@note.title = params[:title]
		@note.note = params[:note]

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
		@note.title = params[:title]
		@note.note = params[:note]

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

		# TODO List items
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

	def update_device
		@device = Device.find(params[:id])
		@device.name = params[:name]
		@device.save
	end

	def update_roku
		@device = Device.find(params[:id])
		if @device.type == 'Roku'
			@device.serial = params[:serial]
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
		@device = Device.new
		@device.serial = params[:serial]
		@device.user_id = current_user.id
		@device.type = 'Roku'
		if current_user.max_devices?
			@device.errors.add(:base, 'You have reached the maximum limit for your registered devices.')
		else
			@device.save
		end
	end

	def update_profile
		@user = current_user
		@user.update_attributes(params)
		@user.save
	end

	def free_trial
		if user_signed_in?
			redirect_to '/account'
		end
	end

	def free_trial_1
		if params[:serial].present?
			serial = params[:serial].upcase
			if serial.include?('O')
				serial = serial.gsub!('O','0')
			end
			@device = Device.new
			@device.serial = serial
		else
			@device = nil
		end


		@user = User.new
		@user.first_name = params[:first_name]
		@user.last_name = params[:last_name]
		@user.email = params[:email]
		@user.phone = params[:phone]
		@user.country = params[:country]
		@user.state = params[:state]
		@user.city = params[:city]
		@user.zip = params[:zip]
		@user.address_1 = params[:address_1]
		@user.address_2 = params[:address_2]
		@user.password = params[:password]
		@user.password_confirmation = params[:password_confirmation]
		if params[:mailchimp].present?
			@user.mailchimp = true
		end



		if @user.valid?
			if @user.mailchimp == true
				mailchimp = Mailchimp::API.new(YAML.load(Setting.where(name: 'MailChimp Credentials').first.data)[:api_key])
				mailchimp.lists.subscribe(YAML.load(Setting.where(name: 'MailChimp Credentials').first.data)[:list_id], { "email" => @user.email})
			end
			if @device.nil?
				@success = true
				@user.save
				sign_in(@user)

				length = Setting.where(name: 'Free Trial Length').first.data
				@user.expiry = Date.today + length.to_i.days
				@user.save
				transaction = Transaction.new
				transaction.user_id = @user.id
				transaction.status = 'Paid'
				transaction.product_details = YAML.dump({name: 'Free Trial', price: 0, duration: length})
				transaction.payment_type = 'N/A'
				transaction.save
				flash[:success] = 'Your free trial has started. It will end on '+@user.expiry.strftime('%B %-d, %Y')+'.'
			else
				@user.save
				@device.user_id = @user.id
				@device.type = 'Roku'

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

					sign_in(@user)

					length = Setting.where(name: 'Free Trial Length').first.data
					@user.expiry = Date.today + length.to_i.days
					@user.save
					transaction = Transaction.new
					transaction.user_id = @user.id
					transaction.status = 'Paid'
					transaction.product_details = YAML.dump({name: 'Free Trial', price: 0, duration: length})
					transaction.customer_paid = DateTime.now
					transaction.payment_type = 'N/A'
					transaction.save
					flash[:success] = 'Your free trial has started. It will end on '+@user.expiry.strftime('%B %-d, %Y')+'.'
				else
					@success = false
					@user.destroy
				end
			end
		else
			@success = false
			@user.destroy
		end

	end
end
