class Admin::OrdersController < ApplicationController
  before_action :authenticate_user!
  layout 'admin'

  def index
    @orders = Order.includes(:billing_address).complete.order('orders.created_at DESC, orders.shipping_status ASC')
  end

  def show
    set_order
  end

  def edit
    set_order
    render json: { modal: render_to_string(partial: 'admin/orders/modal') }, status: 200
  end

  def update
    set_order
    if @order.update(params[:order])
      OrderMailer.tracking(@order).deliver_later if @order.new_order_tracking_mailer?
      render json: { order_id: @order.id }, status: 200
    else 
      render json: { errors: @order.errors.full_messages }, status: 422
    end
  end

  def dispatcher
    set_order
    render json: { modal: render_to_string(partial: 'admin/orders/dispatch/modal', locals: { order: @order }) }, status: 200
  end

  def dispatched
    set_order
    @order.shipping_date = Time.now
    @order.shipping_status = 'dispatched'
    if @order.update(params[:order])
      OrderMailer.dispatched(@order).deliver_later
      render json: 
      { 
        order_id: @order.id, 
        date: @order.updated_at.strftime("%d/%m/%Y"), 
        row: render_to_string(partial: 'admin/orders/single', locals: { order: @order }) 
      }, status: 200
    end
  end

  def receipt
    set_order
    render theme_presenter.page_template_path('emails/orders/preview'), format: [:html], layout: "../themes/#{Store.settings.theme.name}/layout/email"
  end

  def cancel
    set_order
    @order.cancelled!
    @order.restore_stock!
    redirect_to admin_orders_url
  end

  private

  def set_order
    @order ||= Order.active.find(params[:id])
  end
end
