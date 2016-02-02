class StoreController < ApplicationController
    skip_before_action :authenticate_user!

    def home
        @featured_products = Product.active.published.where(featured: true).first(6)
        @news_items = NewsItem.all

        render theme_presenter.page_template_path('store/home'), layout: theme_presenter.layout_template_path
    end
end
