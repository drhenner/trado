class SendDispatchedOrderEmailsJob < ActiveJob::Base
    queue_as :mailers

    def perform
        Order.active.dispatch_today.pending.each do |order|
            if order.shipping_current_hour_or_past?
                OrderMailer.dispatched(order).deliver_later
                order.dispatched!
            end
        end
    end
end
