class CartsController < ApplicationController
    skip_before_action :authenticate_user!
    before_action :validate_cart_items_presence, only: [:checkout]

    def mycart
        set_grouped_countries
        render theme_presenter.page_template_path('carts/mycart'), layout: theme_presenter.layout_template_path
    end

    def checkout
        set_cart_details
        set_grouped_countries
        send_checkout_logs
        if current_cart.order.nil?
            @delivery_id = current_cart.estimate_delivery_id
            @delivery_address = @order.build_delivery_address
            @billing_address = @order.build_billing_address
        else
            @delivery_id = @order.delivery_id
        end
        render theme_presenter.page_template_path('carts/checkout'), layout: theme_presenter.layout_template_path
    end

    def confirm
        set_cart_details
        set_grouped_countries
        set_browser_data
        @order.attributes = params[:order]
        if @order.save
            OrderLog.info("carts#confirm #{user_info_log} #{basic_order_log_info} Successful Order save with [#{@order.payment_type}]")
            @order.calculate(current_cart, Store.tax_rate)
            OrderLog.info("carts#confirm #{user_info_log} #{basic_order_log_info} #{(@order.net_amount.present? && @order.tax_amount.present? && @order.gross_amount.present? && @order.cart_id.present?) ? 'Successful' : 'Failed'} Order Calculation")
            redirect_to Store::PayProvider.new(cart: current_cart, order: @order, provider: @order.payment_type, ip_address: request.remote_ip).build
        else
            OrderLog.error("carts#confirm #{user_info_log} #{basic_order_log_info} Current invalid order object state: #{@order.inspect}")
            OrderLog.error("carts#confirm #{user_info_log} #{basic_order_log_info} List of Order errors: #{@order.errors.messages}")
            render theme_presenter.page_template_path('carts/checkout'), layout: theme_presenter.layout_template_path
        end
    rescue ActiveMerchant::ConnectionError
        OrderLog.error("carts#confirm #{basic_order_log_info} #{@order.payment_type}: This API is temporarily unavailable.")
        flash_message :error, 'An error ocurred when trying to complete your order. Please try again.'  
        Rails.logger.error "#{@order.payment_type}: This API is temporarily unavailable."
        redirect_to checkout_carts_url
    end

    def estimate
        @cart = current_cart
        respond_to do |format|
          if @cart.update(params[:cart])
            format.js { render partial: theme_presenter.page_template_path('carts/delivery_service_prices/estimate/success'), format: [:js] }
          else
            format.json { render json: { errors: @cart.errors.to_json(root: true) }, status: 422 }
          end
        end
    end

    def purge_estimate
        @cart = current_cart
        @cart.estimate_delivery_id = nil
        @cart.estimate_country_name = nil
        @cart.save(validate: false)
        render partial: theme_presenter.page_template_path('carts/delivery_service_prices/estimate/success'), format: [:js]
    end

    private

    def set_cart_details
        @order = current_cart.order.nil? ? Order.new : current_cart.order
        @cart_total = current_cart.calculate(Store.tax_rate)
        @country = @order.delivery_address.nil? ? current_cart.estimate_country_name : @order.delivery_address.country
        @delivery_service_prices = DeliveryServicePrice.find_collection(session[:delivery_service_prices], @country) unless current_cart.estimate_delivery_id.nil? && @order.delivery_address.nil?
    end

    def set_grouped_countries
        @grouped_countries = [Country.popular.map{ |country| [country.name, country.name] }, Country.all.order(name: :asc).map{ |country| [country.name, country.name] }] 
    end

    def validate_cart_items_presence
        redirect_to mycart_carts_url if current_cart.cart_items.empty?
    end

    def set_browser_data
        @order.browser = [browser.device.name,browser.platform.name,browser.name,browser.version].join(' / ') if browser.known?
    end

    def send_checkout_logs
        OrderLog.info("carts#checkout #{basic_order_log_info} #{current_cart.skus.map{|s| s.full_sku }.join(', ')}")
        OrderLog.info("carts#checkout #{basic_order_log_info} Browser: #{[browser.device.name,browser.platform.name,browser.name,browser.version].join(' / ') if browser.known?}")
    end

    def user_info_log
      "Name: #{@order.billing_address.full_name}, Email: #{@order.email} |"
    end

    def basic_order_log_info
        "Cart: [#{current_cart.id}], Order: [#{current_cart.order.try(:id) || @order.try(:id)}] | "
    end
end