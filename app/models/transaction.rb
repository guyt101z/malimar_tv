class Transaction < ActiveRecord::Base
	attr_accessible :user_id, :roku_id, :status, :payment_type, :sales_rep_id, :product_details

	validates_presence_of :user_id, :status, :payment_type, :product_details

	def self.update_daily_data(today)
		data = DailyData.where(date: today).last

		unless data.nil?

			# Transactions Completed
			transactions_completed = Transaction.where(created_at: today.beginning_of_day..today.end_of_day, status: ['Pending','Paid','Refunded'])

			# Total
			data.transactions_completed = transactions_completed.count

			# Value
			transactions_completed_value = 0
			transactions_completed.each do |tx|
				details = YAML.load(tx.product_details)
				transactions_completed_value += details[:price]
			end
			data.transactions_completed_value = transactions_completed_value

			# Transactions Paid
			transactions_paid = Transaction.where(customer_paid: today.beginning_of_day..today.end_of_day, status: ['Paid','Refunded'])

			# Total
			data.transactions_paid = transactions_paid.count

			# Value
			transactions_paid_value = 0
			transactions_paid.each do |tx|
				details = YAML.load(tx.product_details)
				transactions_paid_value += details[:price]
			end
			data.transactions_paid_value = transactions_paid_value


			#Commission Earned
			commission_earned = 0
			transactions_completed.each do |tx|
				unless tx.sales_rep_id.nil?
					details = YAML.load(tx.product_details)
					commission_earned += (details[:commission_rate]/100) * details[:price].to_f
				end
			end
			data.commission_earned = commission_earned

			#Commission Confirmed
			commission_confirmed = 0
			transactions_paid.each do |tx|
				unless tx.sales_rep_id.nil?
					details = YAML.load(tx.product_details)
					commission_confirmed += (details[:commission_rate]/100) * details[:price].to_f
				end
			end
			data.commission_confirmed = commission_confirmed


			data.tx_updated = DateTime.now
			data.save
		end
	end

	def invoice
		user = User.find(user_id)
		tx_details = YAML.load(product_details)
		invoice_details = YAML.load(Setting.where(name: 'Invoice Details').first.data)
		Payday::Config.default.invoice_logo = "#{Rails.root}/public#{InvoiceLogo.first.image_url(:invoice_display)}"
		Payday::Config.default.company_name = "#{invoice_details[:company_name]}"
		Payday::Config.default.company_details = "#{invoice_details[:address]}"

		if status == 'Pending'
			if user.address_2.blank? && user.state.blank?
				invoice = Payday::Invoice.new(invoice_number: id, bill_to: "#{user.name}\n#{user.address_1}\n#{user.city}\n#{user.country}\n#{user.zip}")
			elsif user.state.blank?
				invoice = Payday::Invoice.new(invoice_number: id, bill_to: "#{user.name}\n#{user.address_1}\n#{user.address_2}\n#{user.city}\n#{user.country}\n#{user.zip}")
			elsif user.address_2.blank?
				invoice = Payday::Invoice.new(invoice_number: id, bill_to: "#{user.name}\n#{user.address_1}\n#{user.city}, #{user.state}\n#{user.country}\n#{user.zip}")
			else
				invoice = Payday::Invoice.new(invoice_number: id, bill_to: "#{user.name}\n#{user.address_1}\n#{user.address_2}\n#{user.city}, #{user.state}\n#{user.country}\n#{user.zip}")
			end
		else
			if user.address_2.blank? && user.state.blank?
				invoice = Payday::Invoice.new(invoice_number: id, bill_to: "#{user.name}\n#{user.address_1}\n#{user.city}\n#{user.country}\n#{user.zip}", paid_at: customer_paid.strftime('%B %-d, %Y'))
			elsif user.state.blank?
				invoice = Payday::Invoice.new(invoice_number: id, bill_to: "#{user.name}\n#{user.address_1}\n#{user.address_2}\n#{user.city}\n#{user.country}\n#{user.zip}", paid_at: customer_paid.strftime('%B %-d, %Y'))
			elsif user.address_2.blank?
				invoice = Payday::Invoice.new(invoice_number: id, bill_to: "#{user.name}\n#{user.address_1}\n#{user.city}, #{user.state}\n#{user.country}\n#{user.zip}", paid_at: customer_paid.strftime('%B %-d, %Y'))
			else
				invoice = Payday::Invoice.new(invoice_number: id, bill_to: "#{user.name}\n#{user.address_1}\n#{user.address_2}\n#{user.city}, #{user.state}\n#{user.country}\n#{user.zip}", paid_at: customer_paid.strftime('%B %-d, %Y'))
			end
		end
		invoice.line_items << Payday::LineItem.new(price: tx_details[:price]*100, description: "#{tx_details[:name]} – #{tx_details[:duration]} Month(s)", display_quantity: 1)
		invoice.line_items << Payday::LineItem.new(price: balance_used * -100, description: 'Previous balance used', display_quantity: 1)

		return invoice.render_pdf
	end
end
