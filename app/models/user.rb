class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  	attr_accessible :email, :password, :password_confirmation, :first_name, :last_name, :address_1, :address_2, :city, :state,
                    :country, :zip, :phone, :photo, :expiry, :timezone, :refer_code, :timezone

  	validates_presence_of :first_name
  	validates_presence_of :last_name
  	validates_presence_of :city
  	validates_presence_of :country
  	validates_presence_of :zip
  	validates_presence_of :phone
  	validates_presence_of :address_1
    validates_uniqueness_of :refer_code

  	mount_uploader :photo, ProfileUploader
    searchkick

    def name
      return "#{first_name} #{last_name}"
    end

    def active_for_authentication?
        #remember to call the super
        #then put our own check to determine "active" state using
        #our own "is_active" column
        super and self.is_active?
    end

    def expired?
        if Transaction.where(user_id: id, roku_id: nil).any? && premium? == false
            return true
        else
            return false
        end
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

    def self.authenticate(username, password)
        user = User.find_for_authentication(:email => username)
        unless user.nil?
            user.valid_password?(password) ? user : nil
        end
    end

    def self.update_daily_data(today)
        data = DailyData.where(date: today).last

        unless data.nil?
            data.new_sign_ups = User.where(created_at: today.beginning_of_day..today.end_of_day).count

            # Renewals
            transactions = Transaction.where(created_at: today.beginning_of_day..today.end_of_day)

            total_renewals = 0
            transactions.each do |tx|
                user = User.find(tx.user_id)
                user_txs = Transaction.where(user_id: user.id, status: ['Paid','Refunded','Pending'])

                if user_txs.count > 1
                    total_renewals += 1
                end
            end

            data.renewals = total_renewals

            data.user_updated = DateTime.now
            data.save
        end
    end

    def max_devices?
        max = Setting.where(name: 'Device Limit').first.data.to_i

        devices = Device.where(user_id: id)

        if devices.count >= max && max > 0
            return true
        else
            return false
        end
    end

    def area
        if state.present?
            return "#{city}, #{state}"
        else
            return "#{city}, #{country}"
        end
    end

    def premium?
        return Transaction.where(user_id: id, status: ['Paid','Refunded']).where('? <= ?', :start, Date.today).where('? <= ?', Date.today, :end).any?
    end

    def web_premium?
        return Transaction.where(user_id: id, roku_id: nil, status: ['Paid','Refunded']).where('? <= ?', :start, Date.today).where('? <= ?', Date.today, :end).any?
    end


    def online?
        return last_seen != nil && last_seen > 5.minutes.ago
    end

    def city_state
        if state.present?
            return "#{city}, #{state}"
        else
            return city
        end
    end

    def expiry
        transactions = Transaction.where(user_id: id, roku_id: nil)

        expiration = nil
        transactions.each do |transaction|
            if expiration.nil? && transaction.end != nil
                expiration = transaction.end
            elsif transaction.end.nil? == false && transaction.end > expiration
                expiration = transaction.end
            end
        end
        return expiration
    end
end
