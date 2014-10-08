class Admin::TransactionsController < ApplicationController

  skip_before_action :authenticate_user!, only: :paypal_ipn

  # Integrations have been extracted into a separate gem (https://github.com/Shopify/offsite_payments) and will no longer be loaded by ActiveMerchant 2.x.
  include ActiveMerchant::Billing::Integrations

  def edit
    @transaction = Transaction.includes(:order).find(params[:id])
    @order = @transaction.order
    render :partial => 'admin/orders/transactions/edit', :format => [:js]
  end

  def update
    @transaction = Transaction.find(params[:id])

    respond_to do |format|
      if @transaction.update_attributes(params[:transaction])
        format.js { render :partial => 'admin/orders/transactions/update', :format => [:js] }
      else 
        format.json { render :json => { :errors => @transaction.errors.full_messages}, :status => 422 } 
      end
    end
  end

  # Handler for incoming Instant Payment Notifications from paypal about orders
  def paypal_ipn
    notify = Paypal::Notification.new(request.raw_post)
    
    if notify.acknowledge
      transaction = Transaction.where('order_id = ?', notify.params['invoice']).first
      if notify.complete? and transaction.gross_amount.to_s == notify.params['mc_gross']
        transaction.fee = notify.params['mc_fee']
        transaction.completed!
      else
        transaction.failed!
      end
      if transaction.save
        Mailatron4000::Orders.confirmation_email(transaction.order) rescue Rollbar.report_message("PayPal IPN: Order #{transaction.order.id} confirmation email failed to send", "info", :order => transaction.order)
      end
    end

    render nothing: true
  end
end