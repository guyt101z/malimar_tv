class SystemMailer < ActionMailer::Base
    default to: Proc.new{ Admin.where(role_id: 0).pluck(:email)}
    default from: "Malimar System Daemon <system_daemon@malimar.tv>"

    def daily_report(data)
        @data = data

        @global_css = Setting.where(name: 'Mail Global CSS').first.data
        @header = Setting.where(name: 'Mail Header Markup').first.data
        @footer = Setting.where(name: 'Mail Footer Markup').first.data
        
        mail(subject: "Daily Report for #{data.date.strftime("%B %-d, %Y")}")
    end
end
