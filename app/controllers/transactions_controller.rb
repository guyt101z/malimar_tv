class TransactionsController < ApplicationController
	def accept
		@transaction = Transaction.find(params[:id])
		@user = User.find(@transaction.user_id)
		if @user.expiry.blank?
			details = YAML.load(@transaction.product_details)
			@user.expiry = Date.today+details[:duration].months
			@user.save
		else
			details = YAML.load(@transaction.product_details)
			@user.expiry += details[:duration].months
			@user.save
		end
		@transaction.customer_paid = DateTime.now
		@transaction.status = 'Paid'
		@transaction.save

		TransactionalMailer.order_paid(@transaction, @user).deliver
	end

	def cancel
		@transaction = Transaction.find(params[:id])
		@user = User.find(@transaction.user_id)
		@transaction.customer_refunded = DateTime.now
		@transaction.status = 'Cancelled'
		details = YAML.load(@transaction.product_details)
		details[:plan] = 'CANCELLED: '+ details[:plan]
		@transaction.product_details = YAML.dump(details)
		@transaction.save
	end

	def refund
		@transaction = Transaction.find(params[:id])

		if @transaction.paypal_id.nil?
			@user = User.find(@transaction.user_id)
			@transaction.customer_refunded = DateTime.now
			@transaction.status = 'Refunded'
			@transaction.save
			@message = "Transaction \##{@transaction.id} successfully refunded!"
			@success = true
		else
			@paypal = YAML.load(Setting.where(name: 'Paypal Credentials').first.data)
			gateway = ActiveMerchant::Billing::PaypalGateway.new(
				login:    	@paypal[:login],
				password: 	@paypal[:password],
				signature: 	@paypal[:signature]
			)

			response = gateway.refund nil, @transaction.paypal_id
			if response.success?
				@transaction.status = 'Refunded'
				@transaction.save
				@message = "Transaction \##{@transaction.id} successfully refunded!"
				@success = true
			else
				@success = false
				@message = 'There was an error refunding this transaction.'
			end
		end
	end

	# TODO
	# User view invoice
	# User view all

	# TODO
	# Admin view invoice w/permission

	def view_invoice
		transaction = Transaction.find(params[:id])




		send_data transaction.invoice.render_pdf, filename: "Invoice \##{transaction.id} - #{transaction.created_at.strftime('%d/%M/%Y')}", :type => "application/pdf", :disposition => "inline"

	end

	def view_all
		transactions = Transaction.where(user_id: params[:id]).order(created_at: :desc)
		Payday::Config.default.invoice_logo = "#{Rails.root}/app/assets/images/logo.png"
		Payday::Config.default.company_name = "Malimar TV"
		Payday::Config.default.company_details = "10 This Way\nManhattan, NY 10001\n800-111-2222\nbilling@malimar-tv.com"

		invoice = Payday::Invoice.new(invoice_number: transaction.id, notes: 'This is a full record of your transactions with MalimarTV')

		transactions.each do |transaction|
			details = YAML.load(transaction.product_details)
			invoice.line_items << Payday::LineItem.new(price: details[:price]*100, description: "#{details[:plan]}: #{details[:duration]} month(s) | #{details.status}")
		end
	end
end
