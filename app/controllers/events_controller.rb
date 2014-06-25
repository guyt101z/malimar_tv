class EventsController < ApplicationController
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
end
