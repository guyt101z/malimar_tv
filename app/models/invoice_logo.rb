class InvoiceLogo < ActiveRecord::Base
    attr_accessible :image

    mount_uploader :image, InvoiceLogoUploader
end
