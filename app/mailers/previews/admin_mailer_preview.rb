class AdminMailerPreview < ActionMailer::Preview

    def order_notification
        AdminMailer.order_notification(mock_order)
    end

    def service_notification
        AdminMailer.service_notification('admin@example.com', 'Hey this is a service notification!')
    end

    private

    def mock_order
        Order.active.last
    end
end
