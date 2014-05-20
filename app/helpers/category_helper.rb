module CategoryHelper

    def price_range product
        product.skus.count == 1 ? format_currency(product.skus.first.price) : Store::settings.tax_breakdown ? "from #{format_currency(product.skus.minimum(:price))} (#{gross_price(product.skus.minimum(:price))} inc. #{Store::settings.tax_name})" : "from #{format_currency(product.skus.minimum(:price))}"
    end
end