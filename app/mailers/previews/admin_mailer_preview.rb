class AdminMailerPreview < ActionMailer::Preview

    def order_notification
        AdminMailer.order_notification(mock_order)
    end

    private

    def mock_order
        Order.active.last
    end
end
