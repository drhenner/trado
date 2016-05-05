module DeliveryServicePriceHelper

    def dimension_range min, max
        [min, max].join(' - ')
    end

    # If not delivery price exists, fallback to zero.
    #
    # @param cart_delivery [Object]
    # @return [Integer/Decimal] price of delivery
    #
    def cart_delivery_price cart_delivery
        return cart_delivery.nil? ? 0 : cart_delivery.price
    end

    def delivery_total delivery_price
        net = (current_cart.total_price + delivery_price)
        tax = net * Store.tax_rate
        return Store::Price.new(price: (net + tax)).single
    end

    def delivery_tax delivery_price
        net = (current_cart.total_price + delivery_price)
        tax = net * Store.tax_rate
        return Store::Price.new(price: tax).single
    end
end