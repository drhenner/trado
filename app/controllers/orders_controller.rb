class OrdersController < ApplicationController
    skip_before_action :authenticate_user!

    def confirm
      set_eager_loading_order
      set_address_variables
      validate_confirm_render
      OrderLog.info("orders#confirm #{user_info_log} #{basic_order_log_info} Loaded confirm/review")
    end

    def complete
      set_order
      @order.transfer(current_cart)
      OrderLog.info("orders#complete #{user_info_log} #{basic_order_log_info} Triggering complete order with [#{@order.payment_type}]")
      redirect_to Store::PayProvider.new(order: @order, provider: @order.payment_type, session: session).complete
    end

    def success
      @order = Order.active.includes(:delivery_address).find(params[:id])
      OrderLog.info("orders#success #{user_info_log} #{basic_order_log_info} Succesful Order [#{@order.payment_type}]")
      if @order.latest_transaction.pending? || @order.latest_transaction.completed?
        render theme_presenter.page_template_path('orders/success'), layout: theme_presenter.layout_template_path
      else
        redirect_to root_url 
      end
    end

    def failed
      @order = Order.active.includes(:transactions).find(params[:id])
      OrderLog.info("orders#failed #{user_info_log} #{basic_order_log_info} Failed Order [#{@order.payment_type}]")
      if @order.latest_transaction.failed?
        render theme_presenter.page_template_path('orders/failed'), layout: theme_presenter.layout_template_path
      else
        redirect_to root_url
      end
    end

    def retry
      set_order
      OrderLog.info("orders#retry #{user_info_log} #{basic_order_log_info} Retry Order [#{@order.payment_type}]")
      @error_code = @order.latest_transaction.error_code
      if Payatron4000.fatal_error_code?(@error_code)
        OrderLog.error("orders#retry #{user_info_log} #{basic_order_log_info} Retry Order FATAL [#{@order.payment_type}]")
      else
        @order.update_column(:cart_id, current_cart.id)
      end 
      redirect_to mycart_carts_url
    end

    def destroy
      set_order
      OrderLog.info("orders#destroy #{user_info_log} #{basic_order_log_info} Destroy Order [#{@order.payment_type}]")
      Payatron4000.decommission_order(@order)
      flash_message :success, "Your order has been cancelled."
      redirect_to root_url
    end

    private

    def set_order
      @order ||= Order.active.find(params[:id])
    end

    def set_eager_loading_order
      @order ||= Order.active.includes(:delivery_address, :billing_address).find(params[:id])
    end

    def set_address_variables
      @delivery_address = @order.delivery_address
      @billing_address = @order.billing_address
    end
    
    def validate_confirm_render
      if @order.paypal?
        if params[:token] && params[:PayerID]
          Payatron4000::Paypal.assign_paypal_token(params[:token], params[:PayerID], @order) 
          render theme_presenter.page_template_path('orders/confirm'), layout: theme_presenter.layout_template_path
        else
          flash_message :error, 'An error ocurred when trying to complete your order. Please try again.'
          OrderLog.error("orders#confirm #{user_info_log} #{basic_order_log_info} Missing PayPal verification variables")
          redirect_to checkout_carts_url
        end
      else
        render theme_presenter.page_template_path('orders/confirm'), layout: theme_presenter.layout_template_path
      end
    end

    def user_info_log
      "Name: #{@order.billing_address.full_name}, Email: #{@order.email}, "
    end
end