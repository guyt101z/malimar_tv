class FeedController < ApplicationController
	def load
		if params[:before].present?
			
			@updates = AdminActivity.where(id: 1..(params[:before].to_i-1)).order(id: :desc).limit(6)
		else
			@updates = AdminActivity.all.order(id: :desc).limit(6)
		end
		@timestamp = @updates.last.id if @updates.any?
	end

	def load_admin
		if params[:before].present?
			@where = {before: (params[:before].to_i-1), admin_id: params[:id]}
			@admin_updates = AdminActivity.where(id: 1..(params[:before].to_i-1), admin_id: params[:id]).order(id: :desc).limit(6)
		else
			@admin_updates = AdminActivity.where(admin_id: params[:id]).order(id: :desc).limit(6)
		end
		@timestamp = @admin_updates.last.id if @admin_updates.any?
	end

	def refresh
		@updates = AdminActivity.all.order(id: :desc).limit(6)
		@timestamp = @updates.last.id if @updates.any?
	end

	def view_update
		@update = AdminActivity.find(params[:id])
		@update_data = YAML.load(@update.data)
	end
end
