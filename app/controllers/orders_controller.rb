class OrdersController < ApplicationController
  include Wicked::Wizard

  skip_before_filter :authenticate_user!

  steps :review, :billing, :shipping, :payment, :confirm
  
  # GET /orders/new
  # GET /orders/new.json
  def new
    if current_cart.cart_items.empty?
      flash[:notice] = "Your cart is empty."
      redirect_to root_url
    else
      @order = Order.create(:ip_address => request.remote_ip)
      redirect_to order_build_path(:order_id => @order.id, :id => steps.first)
    end
  end
  
end