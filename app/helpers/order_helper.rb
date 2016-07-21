module OrderHelper

    def order_delivery_label record, status
        class_name = record.dispatched? ? 'green' : record.pending? ? 'orange' : 'red'
        "<span class='label label-#{class_name} label-small'>#{status.capitalize}</span>".html_safe
    end

    def transaction_status_label record, status
        class_name = record.completed? ? 'green' : record.pending? ? 'orange' : 'red'
        "<span class='label label-#{class_name} label-small'>#{status.capitalize}</span>".html_safe
    end

    def selected_country cart, order_address
        order_address.nil? ? cart.estimate_country_name : order_address
    end

    def check_payment_type form_value, session
        form_value == session ? true : false
    end
end