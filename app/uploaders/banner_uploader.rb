# encoding: utf-8

class BannerUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick
  storage :fog

  def store_dir
    "images/banners/#{model.id}"
  end

  version :front_page do
    process :resize_to_fill => [1920, 450]
  end

  version :preview do
      process :resize_to_fit => [300,300]
  end



  def extension_white_list
    %w(jpg jpeg png)
  end

end
