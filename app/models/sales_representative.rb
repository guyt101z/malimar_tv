class SalesRepresentative < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  
  	attr_accessible :email, :password, :password_confirmation, :first_name, :last_name, :address_1, :address_2, :city, :state, :country, :zip, :phone, :photo, :company
  	
  	validates_presence_of :first_name
  	validates_presence_of :last_name
  	validates_presence_of :city
  	validates_presence_of :country
  	validates_presence_of :zip
  	validates_presence_of :phone
    validates_presence_of :address_1
    validates_presence_of :company
    validates_presence_of :commission_rate
  	
  	mount_uploader :photo, ProfileUploader
    
    def name
        return "#{first_name} #{last_name}"
    end
    
    def matches?(search_string)
        if name.downcase.include?(search_string.downcase)
            return true
        elsif email.downcase.include?(search_string.downcase)
            return true
        elsif id.to_s.downcase.include?(search_string.downcase)
            return true
        else
            return false
        end
    end

    def total_commission
        transactions = Transaction.where(sales_rep_id: id)

        total = 0

        transactions.each do |transaction|
            details = YAML.load(transaction.product_details)
            total += details[:price]*(details[:commission_rate]/100) unless transaction.status == 'Cancelled'
        end

        return total
    end

    def commission_owed
        transactions = Transaction.where(sales_rep_id: id, payment_status: 'Pending')

        total = 0

        transactions.each do |transaction|
            details = YAML.load(transaction.product_details)
            total += details[:price]*(details[:commission_rate]/100)
        end

        return total
    end

    def commission_paid
        transactions = Transaction.where(sales_rep_id: id, payment_status: 'Paid')

        total = 0

        transactions.each do |transaction|
            details = YAML.load(transaction.product_details)
            total += details[:price]*(details[:commission_rate]/100)
        end

        return total
    end
end
