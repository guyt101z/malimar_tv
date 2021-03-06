class PlansController < ApplicationController
	def update
		if current_admin.authorized_to?('update_plan_invoice')
			@plan = Plan.find(params[:plan_id])
			unless @plan.features.nil?
				old_plan_details = {name: @plan.name, months: @plan.months, price: @plan.price, features: YAML.load(@plan.features)}
			else
				old_plan_details = {name: @plan.name, months: @plan.months, price: @plan.price, features: nil}
			end
			@plan.name = params[:name]
			@plan.months = params[:months]
			@plan.price = params[:price]
			if params[:features].present?
				features = YAML.dump(params[:features])
			else
				features = nil
			end

			@plan.features = features

			if @plan.save
				unless @plan.features.nil?
					update = AdminActivity.create(admin_id: current_admin.id, data: YAML.dump({type: 'Plan Change', message: "#{current_admin.name} updated a plan.", plan_id: @plan.id, old_plan_details: old_plan_details, new_plan_details: {name: @plan.name, months: @plan.months, price: @plan.price, features: YAML.load(@plan.features)}}))
				else
					update = AdminActivity.create(admin_id: current_admin.id, data: YAML.dump({type: 'Plan Change', message: "#{current_admin.name} updated a plan.", plan_id: @plan.id, old_plan_details: old_plan_details, new_plan_details: {name: @plan.name, months: @plan.months, price: @plan.price, features: nil}}))
				end
			end
		else
			render status: 403
		end
	end
end
