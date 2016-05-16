class AdminMailerPreview < BasePreview

    def order_notification
        AdminMailer.order_notification(mock_order)
    end
end
