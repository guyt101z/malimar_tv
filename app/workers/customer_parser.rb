class CustomerParser
    @queue = :customer_parser

    def self.perform(row)
        user = User.new

        if row['First Name'].present? || row['Last Name'].present?
            user.first_name = row['First Name']
            user.last_name = row['Last Name']
        elsif row['Company'].present?
            user.first_name = row['Company']
        end
        user.email = row['E-mail Address']
        if row['Home Phone'].present?
            user.phone = row['Home Phone']
        elsif row['Business Phone'].present?
            user.phone = row['Business Phone']
        end
        user.mobile_phone = row['Mobile Phone']
        user.address_1 = row['Address']
        user.city = row['City']
        user.state = row['State/Province']
        user.zip = row['ZIP/Postal Code']
        user.country = row['Country']

        if user.email.present?
            user.password = SecureRandom.hex(6)
        end

        code = SecureRandom.hex(6)
        until User.where(refer_code: code).count < 1
            user.refer_code = code
        end

        unless User.where(email: user.email).any?
            user.save(:validate => false)
        end
    end
end
