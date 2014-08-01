class NoteFile < ActiveRecord::Base
    attr_accessible :file, :note_id

    mount_uploader :file, NoteImageUploader
end
