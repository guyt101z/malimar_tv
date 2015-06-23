class SiteController < ApplicationController
	def part
		@site = Setting.where(name: 'site_active').first
		data = YAML.load(@site.data)
	end

	def toggle
		@site = YAML.load(Setting.where(name: 'site_active').first.data)[:active]
	end

	def site_update
		if admin_signed_in? && (current_admin.email == ENV["JOSH_EMAIL"] || current_admin == ENV["ELLIOT_EMAIL"])
			@site = Setting.where(name: 'site_active').first
		else
			redirect_to '/admins'
		end

		if params[:site] == true || params[:site] == 'true'
			@site.data = YAML.dump({active: true})
		else
			@site.data = YAML.dump({active: false})
		end

		@site.save
		redirect_to site_status_path
	end
end
