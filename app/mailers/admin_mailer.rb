class AdminMailer < ActionMailer::Base

    def order_notification order
        @order = order

        mail(to: Store.settings.email, 
            from: "#{Store.settings.name} <#{Store.settings.email}>",
            subject: "#{Store::settings.name} Order Notification"
        ) do |format|
            format.html { render "themes/#{Store.settings.theme.name}/emails/admin/order_notification", layout: "../themes/#{Store.settings.theme.name}/layout/email" }
            format.text { render "themes/#{Store.settings.theme.name}/emails/admin/order_notification", layout: "../themes/#{Store.settings.theme.name}/layout/email" }
        end
    end
end