class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  
  	attr_accessible :email, :password, :password_confirmation, :first_name, :last_name, :address_1, :address_2, :city, :state, :country, :zip, :phone, :photo
  	
  	validates_presence_of :first_name
  	validates_presence_of :last_name
  	validates_presence_of :city
  	validates_presence_of :country
  	validates_presence_of :zip
  	validates_presence_of :phone
  	validates_presence_of :address_1
  	
  	mount_uploader :photo, ProfileUploader
end
