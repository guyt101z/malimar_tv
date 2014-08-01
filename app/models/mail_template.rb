class MailTemplate < ActiveRecord::Base
    attr_accessible :name, :required_variables, :css, :body
end
