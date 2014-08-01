# encoding: utf-8

class NoteImageUploader < CarrierWave::Uploader::Base
    include CarrierWave::MiniMagick
    storage :file

    def store_dir
      "uploads/notes/#{model.note_id}/#{model.id}"
    end

    version :preview do
      process :resize_to_limit => [200, 200]
    end

    def extension_white_list
      %w(jpg jpeg png)
    end
end
