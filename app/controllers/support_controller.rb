class SupportController < ApplicationController


	def sales_rep_create_ticket
		@case = SupportCase.new(params)
		@case.sales_representative_id = current_sales_representative.id
		@case.status = 'Pending'
		@case.save
	end

	def user_create_ticket
		@case = SupportCase.new(params)
		@case.user_id = current_user.id
		@case.status = 'Pending'
		if @case.save
			Resque.enqueue(AdminNotifier, 0, 'ticket', 'A new ticket has been submitted: '+@case.title, admin_view_ticket_path(id: @case.id))
		end
	end

	def user_view_ticket
		@case = SupportCase.find(params[:id])
		@messages = SupportMessage.where(support_case_id: @case.id).order(created_at: :desc)
		@attachments = SupportAttachment.where(support_case_id: @case.id).order(created_at: :desc)
	end

	def user_send_message
		@case = SupportCase.find(params[:case_id])
		@message = SupportMessage.new(user_id: current_user.id, message: params[:message].squish, support_case_id: @case.id)
		if @message.save
			unless @case.admin_id.nil?
				Resque.enqueue(AdminNotifier, @case.admin_id, 'ticket', 'You have a new reply: '+@case.title, admin_view_ticket_path(id: @case.id))
			end
		end
	end

	def user_attach_file
		@case = SupportCase.find(params[:file_case_id])
		@attachment = SupportAttachment.new(support_case_id: params[:file_case_id], file: params[:file])
		if @message.save
			unless @case.admin_id.nil?
				Resque.enqueue(AdminNotifier, @case.admin_id, 'ticket', 'You have a new reply: '+@case.title, admin_view_ticket_path(id: @case.id))
			end
		end
	end

	def sales_rep_view_ticket
		@case = SupportCase.find(params[:id])
		@messages = SupportMessage.where(support_case_id: @case.id).order(created_at: :desc)
		@attachments = SupportAttachment.where(support_case_id: @case.id).order(created_at: :desc)
	end

	def admin_view_ticket
		if current_admin.authorized_to?('manage_support_tickets')
			@case = SupportCase.find(params[:id])
			@messages = SupportMessage.where(support_case_id: @case.id).order(created_at: :desc)
			@attachments = SupportAttachment.where(support_case_id: @case.id).order(created_at: :desc)
		else
			render status: 403
		end
	end

	def accept_ticket
		if current_admin.authorized_to?('manage_support_tickets')
			@case = SupportCase.find(params[:id])
			@case.admin_id = current_admin.id
			@case.status = 'Open'
			@case.save
		else
			render status: 403
		end
	end

	def close_ticket
		if current_admin.authorized_to?('manage_support_tickets')
			@case = SupportCase.find(params[:id])
			@case.status = 'Closed'
			@case.save
		else
			render status: 403
		end
	end

	def reopen_ticket
		if current_admin.authorized_to?('manage_support_tickets')
			@case = SupportCase.find(params[:id])
			@case.status = 'Open'
			@case.save
		else
			render status: 403
		end
	end

	def admin_send_message
		if current_admin.authorized_to?('manage_support_tickets')
			@case = SupportCase.find(params[:case_id])
			@message = SupportMessage.new(admin_id: current_admin.id, message: params[:message].squish, support_case_id: @case.id)
			@message.save
		else
			render status: 403
		end
	end

	def admin_attach_file
		if current_admin.authorized_to?('manage_support_tickets')
			@case = SupportCase.find(params[:file_case_id])
			@attachment = SupportAttachment.new(support_case_id: params[:file_case_id], file: params[:file])
			if @attachment.save
				@message = SupportMessage.new(admin_id: current_admin.id, message: 'Attached a file', support_case_id: @case.id)
				@message.save
			end
		else
			render status: 403
		end
	end

	def sales_rep_create_ticket
		@case = SupportCase.new(params)
		@case.sales_representative_id = current_sales_representative.id
		@case.status = 'Pending'
		if @case.save
			Resque.enqueue(AdminNotifier, 0, 'ticket', 'A new ticket has been submitted: '+@case.title, admin_view_ticket_path(id: @case.id))
		end
	end

	def sales_rep_send_message
		@case = SupportCase.find(params[:case_id])
		@message = SupportMessage.new(sales_representative_id: current_sales_representative.id, message: params[:message].squish, support_case_id: @case.id)
		if @message.save
			unless @case.admin_id.nil?
				Resque.enqueue(AdminNotifier, @case.admin_id, 'ticket', 'You have a new reply: '+@case.title, admin_view_ticket_path(id: @case.id))
			end
		end
	end

	def sales_rep_attach_file
		@case = SupportCase.find(params[:file_case_id])
		@attachment = SupportAttachment.new(support_case_id: params[:file_case_id], file: params[:file])
		@attachment.save
		@message = SupportMessage.new(sales_representative_id: current_sales_representative.id, message: 'Attached a file', support_case_id: @case.id)
		if @message.save
			unless @case.admin_id.nil?
				Resque.enqueue(AdminNotifier, @case.admin_id, 'ticket', 'You have a new reply: '+@case.title, admin_view_ticket_path(id: @case.id))
			end
		end
	end

	def issue_refund
		if current_admin.authorized_to?('manage_support_tickets')
			@case = SupportCase.find(params[:id])
			transaction = Transaction.find(@case.transaction_id)
			transaction.status = 'Refunded'
			transaction.save
		else
			render status: 403
		end
	end
end
