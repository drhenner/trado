class StockWarningEmailJob < ActiveJob::Base
    queue_as :mailers

    def perform
        set_skus
        
    end

    private

    def set_skus
        @skus = Sku.stock_warning
    end
end

