class AdminMailer < ActionMailer::Base

    def order_notification params
        @order = order

        mail(to: Store.settings.email, 
            from: "#{Store.settings.name} <#{Store.settings.email}>",
            subject: "#{Store::settings.name} Order Notification"
        ) do |format|
            format.html { render "themes/#{Store.settings.theme.name}/emails/admin/order_notification", layout: "../themes/#{Store.settings.theme.name}/layout/contact" }
            format.text { render "themes/#{Store.settings.theme.name}/emails/admin/order_notification", layout: "../themes/#{Store.settings.theme.name}/layout/contact" }
        end
    end
end