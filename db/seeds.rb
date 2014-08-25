# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
genres = Genre.create([{name: 'Drama'},{name: 'Comedy'},{name: 'Action'},{name: 'Documentary'}])

plans = [Plan.create(price: 12, months: 1, name: '1 Month', features: YAML.dump(['Feature 1', 'Feature 2'])),
		 Plan.create(price: 33, months: 3, name: '3 Month', features: YAML.dump(['Feature 1', 'Feature 2'])),
		 Plan.create(price: 60, months: 6, name: '6 Month', features: YAML.dump(['Feature 1', 'Feature 2'])),
		 Plan.create(price: 99, months: 12, name: '12 Month', features: YAML.dump(['Feature 1', 'Feature 2']))]

paypal_setting = Setting.create(name: 'Paypal Credentials', data: YAML.dump({login: 'jtate_api1.variationmedia.com', password: '1400603735', signature: 'AFcWxV21C7fd0v3bYYYRCpSSRl31AeXKxTP5ntM4YPwc-sPQTHNXfXts'}))
wowza_token = Setting.create(name: 'WMS Token', data: 'sfV45RvdHJR.658sSSferyhD6HYmlxRt.95Tyg6VGpoz56.dHTeribAdrG654')
withdrawal_limits = Setting.create(name: 'Withdrawal Limits', data: {max: 100, min: 10})

admin = Admin.create(first_name: 'Josh', last_name: 'Tate', password: 'buh12345', email: 'jtate@variationmedia.com', role_id: 0)

invoice_logo = InvoiceLogo.create(image: nil)

invoice_settings = Setting.create(name: 'Invoice Details', data: YAML.dump({company_name: 'Malimar TV', address: "10 This Way\nManhattan, NY 10001\n800-111-2222\nbilling@malimar-tv.com"}))

device_limit = Setting.create(name: 'Device Limit', data: 5)
default_timezone = Setting.create(name: 'Default Timezone', data: 'Pacific Time (US & Canada)')
referral_bonus = Setting.create(name: 'Referral Bonus', data: YAML.dump(method: 'Lump Sum', rate: 5)) # methods are 'Lump Sum' or 'Percentage of Referral Purchase'
free_trial_length = Setting.create(name: 'Free Trial Length', data: 30)
payment_methods = Setting.create(name: 'Payout Methods', data: YAML.dump(['Cheque','Bank Transfer','Paypal','Wire Transfer']))

footer_content = Setting.create(name: 'Footer Content', data: YAML.dump([{name: '', html: ''},{name: '', html: ''},{name: '', html: ''},
	{name: '', html: ''},{name: '', html: ''},{name: '', html: ''},'']))

mail_templates = [
	MailTemplate.create(name: 'Self Sign Up', required_variables: YAML.dump(['user_name','user_email'])),
	MailTemplate.create(name: 'Subscription Reminder', required_variables: YAML.dump(['user_name','user_email', 'expiry_date'])),
	MailTemplate.create(name: 'Admin Register Admin', required_variables: YAML.dump(['admin_name','admin_email','admin_password'])),
	MailTemplate.create(name: 'Admin Register Sales Representative', required_variables: YAML.dump(['rep_email', 'rep_name', 'rep_password'])),
	MailTemplate.create(name: 'Admin Register Customer', required_variables: YAML.dump(['user_email', 'user_name', 'user_password'])),
	MailTemplate.create(name: 'Sales Rep Register Customer', required_variables: YAML.dump(['user_email','user_name','user_password','rep_name','rep_company'])),
	MailTemplate.create(name: 'Order Created', required_variables: YAML.dump(['plan_name','plan_duration','plan_price','created_at'])),
	MailTemplate.create(name: 'Order Paid', required_variables: YAML.dump(['user_name','user_email','plan_name','plan_duration','plan_price','created_at','paid_date','new_expiry'])),
	MailTemplate.create(name: 'Withdrawal Created', required_variables: YAML.dump(['rep_name','rep_email','amount','created_at'])),
	MailTemplate.create(name: 'Withdrawal Approved', required_variables: YAML.dump(['rep_name','rep_email','amount','created_at','approval_date', 'message'])),
	MailTemplate.create(name: 'Withdrawal Denied', required_variables: YAML.dump(['rep_name','rep_email','amount','created_at','denial_date','message']))
]

mail_settings = [
	Setting.create(name: 'MailChimp Credentials', data: YAML.dump({api_key: '0fec58ea225e6267d09236252209fedc-us3', list_id: 'malimar'})),
	Setting.create(name: 'Default Send Address', data: 'donotreply@malimar.tv'),
	Setting.create(name: 'SMTP Credentials', data: YAML.dump({address: 'smtp.mandrillapp.com', port: 587, user_name: 'jtate@variationmedia.com', password: 'eoJXAS4dpN86YIuS6LL48w', domain: 'malimar.tv'})),

	Setting.create(name: 'Mail Header Markup', data: ''),
	Setting.create(name: 'Mail Footer Markup', data: ''),
	Setting.create(name: 'Mail Global CSS', data: ''),

	Setting.create(name: 'Contact Email', data: 'contactus@malimar.tv')
]

background_tasks = [
	BackgroundTask.create(name: 'Clear Admin Activities'),
	BackgroundTask.create(name: 'Clear Duplicate Refer Codes'),
	BackgroundTask.create(name: 'Clear Notifications'),
	BackgroundTask.create(name: 'Clear Unsaved Notes'),
	BackgroundTask.create(name: 'Daily Data Update'),
	BackgroundTask.create(name: 'Subscription Reminder'),
	BackgroundTask.create(name: 'Previous Day\'s Data Update'),
]
