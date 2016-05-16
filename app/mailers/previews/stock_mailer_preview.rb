class StockMailerPreview < ActionMailer::Preview

    def notification
        StockMailer.notification(mock_sku, Store.settings.email)
    end

    private

    def mock_sku
        Sku.active.last
    end
end
