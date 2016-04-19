class ApplicationController < ActionController::Base
    include ApplicationHelper
    before_action :authenticate_user!, :set_tracking_code, :set_tax_rate
    helper_method :current_cart, :theme_presenter

    protected

    def theme_presenter
        ThemePresenter.new(theme: Store.settings.theme)
    end

    def set_tracking_code
        gon.trackingCode = Store.settings.ga_code
    end

    def set_tax_rate
        gon.taxRate = Store.settings.tax_rate
    end

    def amazon_signature
        @aws_sig = AmazonSignature::data_hash
    end

    def s3_resource_sdk
        @s3 = Aws::S3::Resource.new(
            region: Rails.application.secrets.aws_s3_region, 
            credentials: Aws::Credentials.new(Rails.application.secrets.aws_s3_id, Rails.application.secrets.aws_s3_key)
        )
    end

  	def current_cart
        Cart.find(session[:cart_id])
    rescue ActiveRecord::RecordNotFound
  		  cart = Cart.new 
        cart.save(validate: false)
  		  session[:cart_id] = cart.id
  		  return cart
  	end

    def after_sign_out_path_for resource_or_scope
        admin_root_path
    end
end
