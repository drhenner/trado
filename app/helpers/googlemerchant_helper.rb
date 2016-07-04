module GooglemerchantHelper

    def googlemerchant_product_fields f
        render 'admin/product_fields', format: [:html], f: f
    end
end