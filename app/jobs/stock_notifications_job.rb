class StockNotificationsJob < ActiveJob::Base
    queue_as :default

    def perform sku
        sku.active_notifications.each do |notify|
            StockMailer.notification(sku, notify.email).deliver_later
            Mailatron4000.notification_sent(notify)
        end
    end
end

