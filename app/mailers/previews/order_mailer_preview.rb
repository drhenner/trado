class OrderMailerPreview < ActionMailer::Preview

    def completed
        OrderMailer.completed(mock_order)
    end

    def pending
        OrderMailer.pending(mock_order)
    end

    def failed
        OrderMailer.failed(mock_order)
    end

    def dispatched
        OrderMailer.dispatched(mock_order)
    end

    def update_dispatched
        OrderMailer.update_dispatched(mock_order)
    end

    private

    def mock_order
        Order.complete.last
    end
end
