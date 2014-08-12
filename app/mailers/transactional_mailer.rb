class TransactionalMailer < ActionMailer::Base
  default from: Setting.where(name: 'Default Send Address').first.data

	def admin_register_admin(admin, password)
        begin
            @template = MailTemplate.where(name: 'Admin Register Admin').first

            @body = @template.body
            @body.gsub!('*|ADMIN_NAME|*', admin.name)
            @body.gsub!('*|ADMIN_EMAIL|*', admin.email)
            @body.gsub!('*|ADMIN_PASSWORD|*', password)
            @body.gsub!('*|TIMESTAMP|*', DateTime.now.strftime('%l:%m %p'))
            @body.gsub!('*|DATESTAMP|*', DateTime.now.strftime('%B %-d, %Y'))

            @global_css = Setting.where(name: 'Mail Global CSS').first.data
            @header = Setting.where(name: 'Mail Header Markup').first.data
            @footer = Setting.where(name: 'Mail Footer Markup').first.data


    		mail(to: admin.email, subject: @template.subject)
        rescue=> e
            SystemLog.create(error: true, title: 'Admin Register Admin', message: e.message)
        end
	end

	def admin_register_customer(user, password)
        begin
            @template = MailTemplate.where(name: 'Admin Register Customer').first

            @body = @template.body
            @body.gsub!('*|USER_NAME|*', user.name)
            @body.gsub!('*|USER_EMAIL|*', user.email)
            @body.gsub!('*|USER_PASSWORD|*', password)
            @body.gsub!('*|TIMESTAMP|*', DateTime.now.strftime('%l:%m %p'))
            @body.gsub!('*|DATESTAMP|*', DateTime.now.strftime('%B %-d, %Y'))

            @global_css = Setting.where(name: 'Mail Global CSS').first.data
            @header = Setting.where(name: 'Mail Header Markup').first.data
            @footer = Setting.where(name: 'Mail Footer Markup').first.data


            mail(to: user.email, subject: @template.subject)
        rescue=> e
            SystemLog.create(error: true, title: 'Admin Register Customer', message: e.message)
        end
	end

    def admin_register_sales_representative(rep, password)
        begin
            @template = MailTemplate.where(name: 'Admin Register Sales Representative').first

            @body = @template.body
            @body.gsub!('*|REP_NAME|*', rep.name)
            @body.gsub!('*|REP_EMAIL|*', rep.email)
            @body.gsub!('*|REP_PASSWORD|*', password)
            @body.gsub!('*|TIMESTAMP|*', DateTime.now.strftime('%l:%m %p'))
            @body.gsub!('*|DATESTAMP|*', DateTime.now.strftime('%B %-d, %Y'))

            @global_css = Setting.where(name: 'Mail Global CSS').first.data
            @header = Setting.where(name: 'Mail Header Markup').first.data
            @footer = Setting.where(name: 'Mail Footer Markup').first.data


            mail(to: rep.email, subject: @template.subject)
        rescue=> e
            SystemLog.create(error: true, title: 'Admin Register Sales Representative', message: e.message)
        end
    end

    def order_created(transaction, user)
        begin
            details = YAML.load(transaction.product_details)

            @template = MailTemplate.where(name: 'Order Created').first

            @body = @template.body
            @body.gsub!('*|USER_NAME|*', user.name)
            @body.gsub!('*|USER_EMAIL|*', user.email)
            @body.gsub!('*|PLAN_NAME|*', details[:name])
            @body.gsub!('*|PLAN_DURATION|*', view_context.pluralize(details[:duration], 'month'))
            @body.gsub!('*|PLAN_PRICE|*', view_context.number_with_precision(details[:price], precision: 2))
            @body.gsub!('*|CREATED_AT|*', transaction.created_at.strftime('%B %-d, %Y at %l:%m %p'))
            @body.gsub!('*|TIMESTAMP|*', DateTime.now.strftime('%l:%m %p'))
            @body.gsub!('*|DATESTAMP|*', DateTime.now.strftime('%B %-d, %Y'))


            attachments["\##{transaction.id}-#{transaction.created_at.strftime('%B-%d-%Y')}.pdf"] = {
                mime_type: 'application/pdf',
                content: transaction.invoice
            }


            mail(to: user.email, subject: @template.subject)
        rescue=> e
            SystemLog.create(error: true, title: 'Order Created', message: e.message)
        end
    end

    def order_paid(transaction, user)
        begin
            details = YAML.load(transaction.product_details)

            @template = MailTemplate.where(name: 'Order Paid').first

            @body = @template.body
            @body.gsub!('*|USER_NAME|*', user.name)
            @body.gsub!('*|USER_EMAIL|*', user.email)
            @body.gsub!('*|PLAN_NAME|*', details[:name])
            @body.gsub!('*|PLAN_DURATION|*', view_context.pluralize(details[:duration], 'month'))
            @body.gsub!('*|PLAN_PRICE|*', view_context.number_with_precision(details[:price], precision: 2))
            @body.gsub!('*|CREATED_AT|*', transaction.created_at.strftime('%B %-d, %Y at %l:%m %p'))
            @body.gsub!('*|PAID_DATE|*', transaction.customer_paid.strftime('%B %-d, %Y'))
            @body.gsub!('*|NEW_EXPIRY|*', user.expiry.strftime('%B %-d, %Y'))
            @body.gsub!('*|TIMESTAMP|*', DateTime.now.strftime('%l:%m %p'))
            @body.gsub!('*|DATESTAMP|*', DateTime.now.strftime('%B %-d, %Y'))


            attachments["\##{transaction.id}-#{transaction.created_at.strftime('%B-%d-%Y')}.pdf"] = {
                mime_type: 'application/pdf',
                content: transaction.invoice
            }

            mail(to: user.email, subject: @template.subject)
        rescue=> e
            SystemLog.create(error: true, title: 'Order Paid', message: e.message)
        end
    end

    def sales_rep_register_customer(rep, user, password)
        begin
            @template = MailTemplate.where(name: 'Sales Rep Register Customer').first

            @body = @template.body
            @body.gsub!('*|USER_NAME|*', user.name)
            @body.gsub!('*|USER_EMAIL|*', user.email)
            @body.gsub!('*|USER_PASSWORD|*', password)
            @body.gsub!('*|REP_NAME|*', rep.name)
            @body.gsub!('*|REP_COMPANY|*', rep.company)
            @body.gsub!('*|TIMESTAMP|*', DateTime.now.strftime('%l:%m %p'))
            @body.gsub!('*|DATESTAMP|*', DateTime.now.strftime('%B %-d, %Y'))

            @global_css = Setting.where(name: 'Mail Global CSS').first.data
            @header = Setting.where(name: 'Mail Header Markup').first.data
            @footer = Setting.where(name: 'Mail Footer Markup').first.data


            mail(to: user.email, subject: @template.subject)
        rescue=> e
            SystemLog.create(error: true, title: 'Sales Rep Register Customer', message: e.message)
        end
    end

    def self_sign_up(user)
        begin
            @template = MailTemplate.where(name: 'Self Sign Up').first

            @body = @template.body
            @body.gsub!('*|USER_NAME|*', user.name)
            @body.gsub!('*|USER_EMAIL|*', user.email)
            @body.gsub!('*|TIMESTAMP|*', DateTime.now.strftime('%l:%m %p'))
            @body.gsub!('*|DATESTAMP|*', DateTime.now.strftime('%B %-d, %Y'))

            @global_css = Setting.where(name: 'Mail Global CSS').first.data
            @header = Setting.where(name: 'Mail Header Markup').first.data
            @footer = Setting.where(name: 'Mail Footer Markup').first.data


            mail(to: user.email, subject: @template.subject)
        rescue=> e
            SystemLog.create(error: true, title: 'Self Sign Up', message: e.message)
        end
    end

    def subscription_reminder(user)
        begin
            @template = MailTemplate.where(name: 'Subscription Reminder').first

            @body = @template.body
            @body.gsub!('*|USER_NAME|*', user.name)
            @body.gsub!('*|USER_EMAIL|*', user.email)
            @body.gsub!('*|EXPIRY_DATE|*', user.expiry.strftime('%B %-d, %Y'))
            @body.gsub!('*|TIMESTAMP|*', DateTime.now.strftime('%l:%m %p'))
            @body.gsub!('*|DATESTAMP|*', DateTime.now.strftime('%B %-d, %Y'))

            @global_css = Setting.where(name: 'Mail Global CSS').first.data
            @header = Setting.where(name: 'Mail Header Markup').first.data
            @footer = Setting.where(name: 'Mail Footer Markup').first.data


            mail(to: user.email, subject: @template.subject)
        rescue=> e
            SystemLog.create(error: true, title: 'Subscription Reminder', message: e.message)
        end
    end

    def withdrawal_created(withdrawal)
        begin
            @template = MailTemplate.where(name: 'Withdrawal Created').first
            rep = SalesRepresentative.find(withdrawal.sales_rep_id)

            @body = @template.body
            @body.gsub!('*|REP_NAME|*', rep.name)
            @body.gsub!('*|REP_EMAIL|*', rep.email)
            @body.gsub!('*|AMOUNT|*', "$#{view_context.number_with_precision(withdrawal.amount, precision: 2)}")
            @body.gsub!('*|CREATED_AT|*', withdrawal.created_at.strftime('%B %-d, %Y'))
            @body.gsub!('*|TIMESTAMP|*', DateTime.now.strftime('%l:%m %p'))
            @body.gsub!('*|DATESTAMP|*', DateTime.now.strftime('%B %-d, %Y'))

            @global_css = Setting.where(name: 'Mail Global CSS').first.data
            @header = Setting.where(name: 'Mail Header Markup').first.data
            @footer = Setting.where(name: 'Mail Footer Markup').first.data


            mail(to: rep.email, subject: @template.subject)
        rescue=> e
            SystemLog.create(error: true, title: 'Withdrawal Created', message: e.message)
        end
    end

    def withdrawal_denied(withdrawal)
        begin
            @template = MailTemplate.where(name: 'Withdrawal Denied').first
            rep = SalesRepresentative.find(withdrawal.sales_rep_id)

            @body = @template.body
            @body.gsub!('*|REP_NAME|*', rep.name)
            @body.gsub!('*|REP_EMAIL|*', rep.email)
            @body.gsub!('*|AMOUNT|*', "$#{view_context.number_with_precision(withdrawal.amount, precision: 2)}")
            @body.gsub!('*|CREATED_AT|*', withdrawal.created_at.strftime('%B %-d, %Y'))
            @body.gsub!('*|MESSAGE|*', withdrawal.note)
            @body.gsub!('*|DENIAL_DATE|*', withdrawal.updated_at.strftime('%B %-d, %Y'))
            @body.gsub!('*|TIMESTAMP|*', DateTime.now.strftime('%l:%m %p'))
            @body.gsub!('*|DATESTAMP|*', DateTime.now.strftime('%B %-d, %Y'))

            @global_css = Setting.where(name: 'Mail Global CSS').first.data
            @header = Setting.where(name: 'Mail Header Markup').first.data
            @footer = Setting.where(name: 'Mail Footer Markup').first.data


            mail(to: rep.email, subject: @template.subject)
        rescue=> e
            SystemLog.create(error: true, title: 'Withdrawal Denied', message: e.message)
        end
    end

    def withdrawal_approved(withdrawal)
        begin
            @template = MailTemplate.where(name: 'Withdrawal Approved').first
            rep = SalesRepresentative.find(withdrawal.sales_rep_id)

            @body = @template.body
            @body.gsub!('*|REP_NAME|*', rep.name)
            @body.gsub!('*|REP_EMAIL|*', rep.email)
            @body.gsub!('*|AMOUNT|*', "$#{view_context.number_with_precision(withdrawal.amount, precision: 2)}")
            @body.gsub!('*|CREATED_AT|*', withdrawal.created_at.strftime('%B %-d, %Y'))
            @body.gsub!('*|MESSAGE|*', withdrawal.note)
            @body.gsub!('*|APPROVAL_DATE|*', withdrawal.approved.strftime('%B %-d, %Y'))
            @body.gsub!('*|TIMESTAMP|*', DateTime.now.strftime('%l:%m %p'))
            @body.gsub!('*|DATESTAMP|*', DateTime.now.strftime('%B %-d, %Y'))

            @global_css = Setting.where(name: 'Mail Global CSS').first.data
            @header = Setting.where(name: 'Mail Header Markup').first.data
            @footer = Setting.where(name: 'Mail Footer Markup').first.data


            mail(to: rep.email, subject: @template.subject)
        rescue=> e
            SystemLog.create(error: true, title: 'Withdrawal Approved', message: e.message)
        end
    end
end
