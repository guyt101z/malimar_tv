class SupportAttachment < ActiveRecord::Base
	attr_accessible :support_case_id, :file


	mount_uploader :file, SupportUploader
end
