class ErrorsController < ApplicationController
    skip_before_action :authenticate_user!
    
    def show
        set_featured_products if status_code.to_s == '404'
        render theme_presenter.page_template_path("errors/#{status_code.to_s}"), format: [:html], layout: theme_presenter.layout_template_path, status: status_code
    end

    protected

    def status_code
        params[:code] || 500
    end

    def set_featured_products
        @featured_products = Product.active.published.featured.first(6)
    end
end