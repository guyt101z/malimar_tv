class Category < ActiveRecord::Base
    attr_accessible :name, :genre, :content_type, :content_quality, :item_type, :rank, :free

    validates_presence_of :name, :item_type, :rank
    validates_inclusion_of :free, in: [true,false], message: 'must be selected'
end
