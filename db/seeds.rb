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

paypal_setting = Setting.create(name: 'Paypal Credentials', login: 'jtate_api1.variationmedia.com', password: '1400603735', signature: 'AFcWxV21C7fd0v3bYYYRCpSSRl31AeXKxTP5ntM4YPwc-sPQTHNXfXts')

admin = Admin.create(first_name: 'Josh', last_name: 'Tate', password: 'buh12345', email: 'jtate@variationmedia.com')
