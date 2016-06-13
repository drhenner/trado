class Admin::DeliveryServicesController < ApplicationController
  before_action :authenticate_user!
  layout "admin"

  def index
    set_all_countries
    @delivery_services = DeliveryService.active.includes(:prices).load
  end

  def new
    set_all_countries
    @delivery_service = DeliveryService.new
  end

  def edit
    set_delivery_service
    set_all_countries
    @form_delivery_service = DeliveryService.find(params[:id])
  end

  def create
    set_all_countries
    @delivery_service = DeliveryService.new(params[:delivery_service])

    if @delivery_service.save
      flash_message :success, 'Delivery service was successfully created.'
      redirect_to admin_delivery_services_url
    else
      render :new
    end
  end

  def update
    set_delivery_service
    set_all_countries
    unless @delivery_service.orders.empty?
      Store.inactivate!(@delivery_service)
      @old_delivery_service = @delivery_service
      @delivery_service = DeliveryService.new(params[:delivery_service])
    end

    if @delivery_service.update(params[:delivery_service])
      if @old_delivery_service
        @old_delivery_service.prices.active.each do |price|
          new_price = price.dup
          new_price.delivery_service_id = @delivery_service.id
          new_price.save(validate: false)
        end
        Store.inactivate_all!(@old_delivery_service.prices)
        @old_delivery_service.prices.map { |p| p.destroy if p.orders.empty? }
      end
      flash_message :success, 'Delivery service was successfully updated.'
      redirect_to admin_delivery_services_url
    else
      @form_delivery_service = @old_delivery_service ||= DeliveryService.find(params[:id])
      Store.activate!(@form_delivery_service)
      @form_delivery_service.attributes = params[:delivery_service]
      render :edit
    end
  end

  def destroy
    set_delivery_service
    set_all_countries
    if @delivery_service.orders.empty?
      @result = Store.last_record(@delivery_service, DeliveryService.active.load.count)
    else
      Store.inactivate!(@delivery_service)
    end
    @result = [:success, 'Delivery service was successfully deleted.'] if @result.nil?
    flash_message @result[0], @result[1]
    redirect_to admin_delivery_services_url
  end

  def copy_countries
    set_all_countries
    @delivery_services = params[:delivery_service_id].blank? ? DeliveryService.active.load : DeliveryService.where('id != ?', params[:delivery_service_id]).active.load
    render json: { modal: render_to_string(partial: 'admin/delivery_services/countries/modal', locals: { delivery_services: @delivery_services }) }, status: 200
  end

  def set_countries
    set_all_countries
    @delivery_service = DeliveryService.includes(:countries).find(params[:delivery_service_id])
    render json: { countries: @delivery_service.countries.map{ |c| c.id.to_s } }, status: 200
  rescue ActiveRecord::RecordNotFound
    render json: { errors: 'You need to select a delivery service.' }, status: 422
  end

  private

  def set_delivery_service
    @delivery_service = DeliveryService.find(params[:id])
  end

  def set_all_countries
    @countries = Country.all
  end
end
