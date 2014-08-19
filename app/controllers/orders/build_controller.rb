class Orders::BuildController < ApplicationController
  include Wicked::Wizard

  skip_before_action :authenticate_user!

  before_action :check_order_status, only: :show

  before_action :accessible_order, except: [:success, :failure]

  steps :review, :billing, :shipping, :payment, :confirm

  ###################################
  # ORDER VIEW LOGIC
  ###################################
  # Displays the front-end content of each step, with specific methods throughout providing the relevant data
  # Steps include, in this order: review, billing, shipping, payment then confimration
  #
  def show
    @cart = current_cart
    ################
    # Sets current state of the order
    @order.status = step == steps.last ? :active : step
    @order.save(validate: false)
    ################
    case step
    when :billing
      @billing_address = @order.billing_address
    end
    case step
    when :shipping
      @delivery_address = @order.delivery_address
      @delivery_service_prices = DeliveryServicePrice.find_collection(current_cart, @delivery_address.country) unless @order.delivery_id.nil?
    end
    case step 
    when :payment
      @order.calculate(current_cart, Store::tax_rate)
    end
    case step
    when :confirm
      Payatron4000::Paypal.assign_paypal_token(params[:token], params[:PayerID], @order) if params[:token] && params[:PayerID]
    end
    render_wizard
  end
  ###################################

  ###################################
  # ORDER UPDATE LOGIC
  ###################################
  # When advancing to the next step in the order process, the update method is called
  # Any bespoke business logic in each step is then triggered, for example: updating the address and the order status attribute value
  #
  def update 
    @cart = current_cart
    case step 
    when :billing
      @billing_address = @order.billing_address
      # Update billing attributes
      if @billing_address.update(params[:address])
        # Update order attributes in the form
        unless @order.update(params[:order])
          # if unsuccessful re-render the form with order errors
          render_wizard @order
        else
          # else continue to the next stage
          render_wizard @billing_address
        end
      else
        render_wizard @billing_address
      end  
    end
    case step
    when :shipping
      @delivery_address = @order.delivery_address
      # Update billing attributes
      if @delivery_address.update(params[:address])
        # Update order attributes in the form
        unless @order.update(params[:order])
          # if unsuccessful re-render the form with order errors
          render_wizard @order
        else
          # else continue to the next stage
          render_wizard @delivery_address
        end
      else
        render_wizard @delivery_address
      end
    end
    case step
    when :confirm
      if @order.update(params[:order])
        @order.transfer(current_cart)
        unless session[:payment_type].nil?
          url = Payatron4000::Generic.complete(@order, session[:payment_type], session)
        else
          url = Payatron4000::Paypal.complete(@order, session)
        end
        redirect_to url
      else
        render_wizard @order
      end
    end
  end
  ###################################

  ################################### 
  # ORDER PAYMENT TYPES 
  ###################################
  # Prepares the order data and redirects to the PayPal login page to review the order
  # Set the payment_type session value to nil in order to prevent the wrong complete method being fired in the purchase method below
  # Bespoke PayPal method
  #
  def express
    session[:payment_type] = nil
    response = EXPRESS_GATEWAY.setup_purchase(Store::Price.new(@order.gross_amount, 'net').singularize, 
                                              Payatron4000::Paypal.express_setup_options( @order, 
                                                                                          steps, 
                                                                                          current_cart,
                                                                                          request.remote_ip, 
                                                                                          order_build_url(:order_id => @order.id, :id => steps.last), 
                                                                                          order_build_url(:order_id => @order.id, :id => 'payment')
                                              )
    )
    if response.success?
      redirect_to EXPRESS_GATEWAY.redirect_url_for(response.token)
    else
      begin
        Payatron4000::Paypal.failed(response, @order)
      rescue Exception => e
        Rollbar.report_exception(e)
      end
      @order.update_column(:cart_id, nil) 
      redirect_to failure_order_build_url( :order_id => @order.id, :id => 'confirm', :response => response.message, :error_code => response.params["error_codes"])
    end
  end 

  # Payment method for a bank transfer, which sets the payment_type session value to Bank tranfer
  # Redirect to last step in the order process
  #
  def bank_transfer
    session[:payment_type] = 'Bank transfer' 
    redirect_to order_build_url(:order_id => @order.id, :id => steps.last)
  end

  # Payment method for a cheque, which sets the payment_type session value to Cheque
  # Redirect to last step in the order process
  #
  def cheque
    session[:payment_type] = 'Cheque'
    redirect_to order_build_url(:order_id => @order.id, :id => steps.last)
  end
  ###################################

  ###################################
  # ORDER OUTCOME METHODS
  ###################################
  # Renders the successful order page, however redirected if the order payment status is not Pending or completed.
  #
  def success
    @order = Order.includes(:delivery_address).find(params[:order_id])
    redirect_to root_url unless @order.transactions.last.pending? || @order.transactions.last.completed?
  end

  # Renders the failed order page, however redirected if the order payment stautus it not Failed
  #
  def failure
    @order = Order.includes(:transactions).find(params[:order_id])
    redirect_to root_url unless @order.transactions.last.failed?
  end

  # When an order has failed, the user has an option to retry the order
  # Although if it has a PayPal error code of 10412 or 10415, create a new order and redirect to review
  # 
  def retry
    @error_code = @order.transactions.last.error_code
    if @error_code == 10412 || @error_code == 10415
      redirect_to new_order_path
    else
      @order.update_column(:cart_id, session[:cart_id])
      redirect_to order_build_url(order_id: @order.id, id: 'review')
    end
  end

  # When an order has failed, the user has an option to discard order
  # However it's details are retained in the database.
  #
  def purge
    @order.update_column(:cart_id, nil)
    flash_message :success, "Your order has been cancelled."
    redirect_to root_url
  end
  ###################################

  ###################################
  # ORDER ESTIMATE DELIVERY PRICE
  ###################################
  def estimate
    respond_to do |format|
      if @order.update(params[:order])
        format.js { render partial: 'orders/delivery_service_prices/estimate/success', format: [:js] }
      else
        format.json { render json: { errors: @order.errors.to_json(root: true) }, status: 422 }
      end
    end
  end

  # Destroys the estimated delivery price item from the cart by setting all the session stores values to nil
  #
  def purge_estimate
    @order.delivery_id = nil
    @order.delivery_address.country = nil
    @order.save(validate: false)
    render :partial => 'orders/delivery_service_prices/estimate/success', :format => [:js]
  end
  ###################################

  ###################################
  # ORDER PRIVATE METHODS
  ###################################
  private

  # Before filter method to check if the order has an associated transaction record with a payment_status of completed
  # Or if the the current_cart is empty, and if so redirect to the homepage.
  #
  def accessible_order
    @order = Order.find(params[:order_id])
    if @order.completed? || current_cart.cart_items.empty?
      flash_message :error, "You do not have permission to amend this order."
      redirect_to root_url
    end
  end

  # Before filter method to validate whether the user is allowed to access a specific step in the order process
  # If not they are redirected to the required step before proceeding further
  #
  def check_order_status
    @order = Order.find(params[:order_id])
    route = (steps.last(3).include?(params[:id].to_sym) && @order.billing_address.first_name.nil?) ? 'billing' 
            : (steps.last(2).include?(params[:id].to_sym) && (@order.delivery_address.first_name.nil? || @order.delivery_id.nil?)) ? 'shipping' 
            : steps.last(1).include?(params[:id].to_sym) && (params[:token].nil? || params[:PayerID].nil?) ? 'payment' 
            : nil
    redirect_to order_build_url(order_id: @order.id, id: route) unless route.nil?
  end
  ###################################
end