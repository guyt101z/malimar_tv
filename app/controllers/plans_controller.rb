class PlansController < ApplicationController
	def update
		@plan = Plan.find(params[:plan_id])
		@plan.name = params[:name]
		@plan.months = params[:months]
		@plan.price = params[:price]
		if params[:features].present?
			features = YAML.dump(params[:features])
		else
			features = nil
		end

		@plan.features = features

		@plan.save
	end
end
