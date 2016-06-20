class Admin::TransactionsController < ApplicationController
    skip_before_action :authenticate_user!, only: :paypal_ipn
    include ActiveMerchant::Billing::Integrations

    def edit
        @transaction = Transaction.includes(:order).find(params[:id])
        render json: { modal: render_to_string(partial: 'admin/orders/transactions/modal') }, status: 200
    end

    def update
        @transaction = Transaction.find(params[:id])

        if @transaction.update_attributes(params[:transaction])
            Payatron4000.set_order_invoice_id(@transaction.order)
            Mailatron4000::Orders.confirmation_email(@transaction.order)
            render json: { transaction: render_to_string(partial: 'admin/orders/transactions/single', locals: { transaction: @transaction }), invoice_id: @transaction.order.invoice_id }, status: 200
        else 
            render json: { errors: @transaction.errors.full_messages}, status: 422
        end
    end

    # Handler for incoming Instant Payment Notifications from paypal about orders
    def paypal_ipn
        notify = Paypal::Notification.new(request.raw_post)
    
        if notify.acknowledge
            transaction = Transaction.where(order_id: notify.params['invoice']).first
            if notify.complete? and transaction.gross_amount.to_s == notify.params['mc_gross']
                transaction.fee = notify.params['mc_fee']
                transaction.completed!
                Payatron4000.set_order_invoice_id(transaction.order)
            else
                transaction.failed!
            end
            Mailatron4000::Orders.confirmation_email(transaction.order) if transaction.save
        end

        render nothing: true
    end
end