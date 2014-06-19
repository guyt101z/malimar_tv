class TransactionalMailer < ActionMailer::Base
  default from: "donotreply@malimar.com"

  	def new_user(user, password)
  		@user = user
  		@password = password

  		mail(to: @user.email, subject: 'Your New Malimar TV Account')
  	end

  	def new_rep(rep, password)
  		@rep = rep
  		@password = password

  		mail(to: @rep.email, subject: 'Sales Representative Details')
  	end
end
