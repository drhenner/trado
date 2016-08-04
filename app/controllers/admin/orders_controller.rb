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
    @order.validate_shipping_date!
    if @order.update(params[:order])
      OrderMailer.update_dispatched(@order).deliver_later if @order.new_order_tracking_mailer? || @order.changed_shipping_date?
      render json: 
      { 
        order_id: @order.id,
        date: @order.shipping_date.strftime("%d/%m/%Y %R"),
        row: render_to_string(partial: 'admin/orders/single', locals: { order: @order })
      }, status: 200
    else 
      render json: { errors: @order.errors.full_messages }, status: 422
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
