class AdminMailer < ActionMailer::Base

    def order_notification order
        @order = order

        mail(to: Store.settings.email, 
            from: "#{Store.settings.name} <#{Store.settings.email}>",
            subject: "[#{@order.billing_address.full_name}] Gimson Robotics Order Notification, ID #{@order.legacy_order_id}"
        ) do |format|
            format.html { render "themes/#{Store.settings.theme.name}/emails/admin/order_notification", layout: "../themes/#{Store.settings.theme.name}/layout/email" }
            format.text { render "themes/#{Store.settings.theme.name}/emails/admin/order_notification", layout: "../themes/#{Store.settings.theme.name}/layout/email" }
        end
    end

    def service_notification email, content
        @content = content

        mail(to: email, 
            from: "#{Store.settings.name} <#{Store.settings.email}>",
            subject: "Gimson Robotics Service Notification"
        ) do |format|
            format.html { render "themes/#{Store.settings.theme.name}/emails/admin/service_notification", layout: "../themes/#{Store.settings.theme.name}/layout/email" }
            format.text { render "themes/#{Store.settings.theme.name}/emails/admin/service_notification", layout: "../themes/#{Store.settings.theme.name}/layout/email" }
        end
    end
end