module OrderHelper

    def status_label record, status
        if record.class == Order
            class_name = record.dispatched? ? 'green' : record.pending? ? 'orange' : 'red'
        elsif record.class == Transaction
            class_name = record.completed? ? 'green' : record.pending? ? 'orange' : 'red'
        end
      "<span class='label label-#{class_name} label-small'>#{status.capitalize}</span>".html_safe
    end

    def selected_country cart, order_address
        order_address.nil? ? cart.estimate_country_name : order_address
    end

    def check_payment_type form_value, session
        form_value == session ? true : false
    end
end