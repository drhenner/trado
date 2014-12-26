class Admin::NewsItemsController < ApplicationController
    before_action :set_news_item, only: [:edit, :update, :destroy]
    layout 'admin'

    def index 
        @news_items = NewsItem.all
    end

    def new
        @news_item = NewsItem.new
    end

    def create
        @news_item = NewsItem.new(params[:news_item])

        if @news_item.save
            flash_message :success, "News item was successfully created."
            redirect_to admin_news_items_url
        else
            render action: :new
        end
    end

    def edit
    end

    def update
        if @news_item.update(params[:news_item])
            flash_message :success, "News item was successfully updated."
            redirect_to admin_news_items_url
        else
            render action: :edit
        end
    end

    def destroy
        flash_message :success, "News item was successfully deleted."
        redirect_to admin_news_items_url
    end

    private

    def set_news_item
        @news_item = NewsItem.find(params[:id])
    end
end