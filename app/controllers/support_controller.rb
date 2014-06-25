class SupportController < ApplicationController
	include ActionController::Live

	def admin_events
		response.headers["Content-Type"] = "text/event-stream"
		start = Time.zone.now
		support_case = SupportCase.find(params[:id])
		if support_case.user_id != nil
			redis = Redis.new
			redis.subscribe("user_message.create.#{params[:id]}") do |on|
				on.message do |event, data|
					response.stream.write "data: #{data}\n\n"
				end
			end
		elsif support_case.sales_representative_id != nil
			redis = Redis.new
			redis.subscribe("sales_rep_message.create.#{params[:id]}") do |on|
				on.message do |event, data|
					response.stream.write "data: #{data}\n\n"
				end
			end
		end
		sleep 2
		rescue IOError
			logger.info "Stream closed"
		ensure
			response.stream.close
	end

	def sales_rep_events
		response.headers["Content-Type"] = "text/event-stream"
		redis = Redis.new
		redis.subscribe("admin_message.create.#{params[:id]}") do |on|
			on.message do |event, data|
				response.stream.write "data: #{data}\n\n"
			end
		end
		sleep 2
		rescue IOError
			logger.info "Stream closed"
		ensure
			response.stream.close
	end

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
		if @message.save
			$redis.publish("admin_message.create.#{@case.id}", {kind: 'message', message: @message.message, timestamp: @message.created_at, name: current_admin.name}.to_json)
		end
	end

	def admin_attach_file
		@case = SupportCase.find(params[:file_case_id])
		@attachment = SupportAttachment.new(support_case_id: params[:file_case_id], file: params[:file])
		if @attachment.save
			@message = SupportMessage.new(admin_id: current_admin.id, message: 'Attached a file', support_case_id: @case.id)
			@message.save
			$redis.publish("admin_message.create.#{@case.id}", {kind: 'file', message: @message.message, timestamp: @message.created_at, name: current_admin.name, file_url: @attachment.file_url}.to_json)
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
		if @message.save
			$redis.publish("sales_rep_message.create.#{@case.id}", {kind: 'message', message: @message.message, timestamp: @message.created_at, name: current_sales_representative.name}.to_json)
		end
	end

	def sales_rep_attach_file
		@case = SupportCase.find(params[:file_case_id])
		@attachment = SupportAttachment.new(support_case_id: params[:file_case_id], file: params[:file])
		if @attachment.save
			@message = SupportMessage.new(sales_representative_id: current_sales_representative.id, message: 'Attached a file', support_case_id: @case.id)
			@message.save
			$redis.publish("sales_rep_message.create.#{@case.id}", {kind: 'file', message: @message.message, timestamp: @message.created_at, name: current_sales_representative.name, file_url: @attachment.file_url}.to_json)
		end
	end
end
