task :sub_reminder => :environment do
    users = User.where(expiry: [15.days.from_now.to_date,7.days.from_now.to_date])

    users.each do |user|
        TransactionalMailer.subscription_reminder(user).deliver
    end
end
