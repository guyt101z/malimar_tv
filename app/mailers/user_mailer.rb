class UserMailer < MandrillMailer::TemplateMailer
  default from: "mailer@malimar_tv.com"
  	default from_name: 'Malimar TV'
  	def new_account(user, password)
  		mandrill_mail template: 	'Malimar New User',
  					  subject: 		'Your new account',
  					  to: 			user.email,
  					  vars: 		{'USER_NAME' => user.first_name, 'PASSWORD' => password}
  	end
end
