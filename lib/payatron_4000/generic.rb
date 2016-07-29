module Payatron4000

    class Generic

        # Redirects the user to the confirm order template
        #
        # @param cart [Object]
        # @param order [Object]
        # @param ip_address [String]
        # @return [String] redirect url
        def self.build cart, order, ip_address
            return Rails.application.routes.url_helpers.confirm_order_url(order)
        end

        # Upon successfully completing an order a new transaction record is created, stock is updated for the relevant SKU
        #
        # @param order[Object]
        # @param payment_type [String]
        def self.successful order, payment_type
            Transaction.new( :fee => 0, 
                :gross_amount => order.gross_amount, 
                :order_id => order.id, 
                :payment_status => 'pending', 
                :transaction_type => 'Credit', 
                :tax_amount => order.tax_amount, 
                :paypal_id => nil, 
                :payment_type => payment_type,
                :net_amount => order.net_amount,
                :status_reason => nil
            ).save(validate: false)
            Payatron4000::update_stock(order)
            Payatron4000::increment_product_order_count(order.products)
        end

        # Completes the order process by creating a transaction record, sending a confirmation email and redirects the user
        #
        # @param order [Object]
        # @param session [Object]
        # @param payment_type [String]
        def self.complete order, session, payment_type
            order.transfer(order.cart)
            Payatron4000::decommission_order(order)
            Payatron4000::Generic.successful(order, payment_type)
            Payatron4000::destroy_cart(session)
            order.reload
            Mailatron4000::Orders.confirmation_email(order)
            AdminMailer.order_notification(order).deliver_later
            return Rails.application.routes.url_helpers.success_order_url(order)
        end
    end
end
