class OrdersController < ApplicationController

    skip_before_action :authenticate_user!
    before_action :set_order, only: [:destroy, :retry, :complete]
    before_action :set_and_validate_order, only: :confirm

    def confirm
      @delivery_address = @order.delivery_address
      @billing_address = @order.billing_address
      render theme_presenter.page_template_path('orders/confirm'), layout: theme_presenter.layout_template_path
    end

    def complete
      @order.transfer(current_cart)
      redirect_to Store::PayProvider.new(order: @order, provider: session[:payment_type], session: session).complete
    end

    def success
      @order = Order.includes(:delivery_address).find(params[:id])
      if @order.transactions.last.pending? || @order.transactions.last.completed?
        render theme_presenter.page_template_path('orders/success'), layout: theme_presenter.layout_template_path
      else
        redirect_to root_url 
      end
    end

    def failed
      @order = Order.includes(:transactions).find(params[:id])
      if @order.transactions.last.failed?
        render theme_presenter.page_template_path('orders/failed'), layout: theme_presenter.layout_template_path
      else
        redirect_to root_url
      end
    end

    def retry
      @error_code = @order.transactions.last.error_code
      @order.update_column(:cart_id, current_cart.id) unless Payatron4000::fatal_error_code?(@error_code)
      redirect_to mycart_carts_url
    end

    def destroy
      Payatron4000::decommission_order(@order)
      flash_message :success, "Your order has been cancelled."
      redirect_to root_url
    end

    private

    def set_order
      @order = Order.find(params[:id])
    end

    def set_and_validate_order
      @order = Order.includes(:delivery_address, :billing_address).find(params[:id])
      if session[:payment_type] == 'express-checkout'
        if params[:token] && params[:PayerID]
          Payatron4000::Paypal.assign_paypal_token(params[:token], params[:PayerID], @order) 
        else
          flash_message :error, 'An error ocurred when trying to complete your order. Please try again.'
          Rails.logger.warn "Missing PayPal verification variables for order ##{@order.id}."
          redirect_to checkout_carts_url
        end
      end
    end
end