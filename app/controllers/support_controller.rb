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
		@case.save
	end

	def sales_rep_view_ticket
		@case = SupportCase.find(params[:id])
		@messages = SupportMessage.where(support_case_id: @case.id).order(created_at: :desc)
		@attachments = SupportAttachment.where(support_case_id: @case.id).order(created_at: :desc)
	end

	def admin_view_ticket
		@case = SupportCase.find(params[:id])
		@messages = SupportMessage.where(support_case_id: @case.id).order(created_at: :desc)
		@attachments = SupportAttachment.where(support_case_id: @case.id).order(created_at: :desc)
	end

	def accept_ticket
		@case = SupportCase.find(params[:id])
		@case.admin_id = current_admin.id
		@case.status = 'Open'
		@case.save
	end

	def close_ticket
		@case = SupportCase.find(params[:id])
		@case.status = 'Closed'
		@case.save
	end

	def reopen_ticket
		@case = SupportCase.find(params[:id])
		@case.status = 'Open'
		@case.save
	end

	def admin_send_message
		@case = SupportCase.find(params[:case_id])
		@message = SupportMessage.new(admin_id: current_admin.id, message: params[:message].squish, support_case_id: @case.id)
		@message.save
	end

	def admin_attach_file
		@case = SupportCase.find(params[:file_case_id])
		@attachment = SupportAttachment.new(support_case_id: params[:file_case_id], file: params[:file])
		if @attachment.save
			@message = SupportMessage.new(admin_id: current_admin.id, message: 'Attached a file', support_case_id: @case.id)
			@message.save
		end
	end

	def sales_rep_create_ticket
		@case = SupportCase.new(params)
		@case.sales_representative_id = current_sales_representative.id
		@case.status = 'Pending'
		@case.save
	end

	def sales_rep_send_message
		@case = SupportCase.find(params[:case_id])
		@message = SupportMessage.new(sales_representative_id: current_sales_representative.id, message: params[:message].squish, support_case_id: @case.id)
		@message.save
	end

	def sales_rep_attach_file
		@case = SupportCase.find(params[:file_case_id])
		@attachment = SupportAttachment.new(support_case_id: params[:file_case_id], file: params[:file])
		if @attachment.save
			@message = SupportMessage.new(sales_representative_id: current_sales_representative.id, message: 'Attached a file', support_case_id: @case.id)
			@message.save
		end
	end
end
