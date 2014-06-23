class TransactionsController < ApplicationController
	def accept

	end

	def cancel

	end

	def refund
		
	end

	def view_invoice
		transaction = Transaction.find(params[:id])
		user = User.find(transaction.user_id)
		Payday::Config.default.invoice_logo = "#{Rails.root}/app/assets/images/logo.png"
		Payday::Config.default.company_name = "Malimar TV"
		Payday::Config.default.company_details = "10 This Way\nManhattan, NY 10001\n800-111-2222\nbilling@malimar-tv.com"

		if user.address_2.blank? && user.state.blank?
			invoice = Payday::Invoice.new(invoice_number: transaction.id, bill_to: "#{user.name}\n#{user.address_1}\n#{user.city}\n#{user.country}\n#{user.zip}")
		elsif user.state.blank?
			invoice = Payday::Invoice.new(invoice_number: transaction.id, bill_to: "#{user.name}\n#{user.address_1}\n#{user.address_2}\n#{user.city}\n#{user.country}\n#{user.zip}")
		elsif user.address_2.blank?
			invoice = Payday::Invoice.new(invoice_number: transaction.id, bill_to: "#{user.name}\n#{user.address_1}\n#{user.city}, #{user.state}\n#{user.country}\n#{user.zip}")
		else
			invoice = Payday::Invoice.new(invoice_number: transaction.id, bill_to: "#{user.name}\n#{user.address_1}\n#{user.address_2}\n#{user.city}, #{user.state}\n#{user.country}\n#{user.zip}")
		end
		details = YAML.load(transaction.product_details)
		invoice.line_items << Payday::LineItem.new(price: details[:price]*100, description: "#{details[:plan]}: #{details[:duration]} month(s)", display_quantity: 1)


		send_data invoice.render_pdf, filename: "Invoice \##{transaction.id} - #{transaction.created_at.strftime('%d/%M/%Y')}", :type => "application/pdf", :disposition => "inline"
		
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
