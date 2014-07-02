class Admin::ZonesController < ApplicationController

  before_filter :authenticate_user!
  layout "admin"
  # GET /zones
  # GET /zones.json
  def index
    @zones = Zone.includes(:countries).all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @zones }
    end
  end

  # GET /zones/new
  # GET /zones/new.json
  def new
    @zone = Zone.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @zone }
    end
  end

  # GET /zones/1/edit
  def edit
    @zone = Zone.find(params[:id])
  end

  # POST /zones
  # POST /zones.json
  def create
    @zone = Zone.new(params[:zone])

    respond_to do |format|
      if @zone.save
        flash_message :success, 'Zone was successfully created.'
        format.html { redirect_to admin_zones_url }
        format.json { render json: @zone, status: :created, location: @zone }
      else
        format.html { render action: "new" }
        format.json { render json: @zone.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /zones/1
  # PUT /zones/1.json
  def update
    @zone = Zone.find(params[:id])
    respond_to do |format|
      if @zone.update_attributes(params[:zone])
        flash_message :success, 'Zone was successfully updated.'
        format.html { redirect_to admin_zones_url }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @zone.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /zones/1
  # DELETE /zones/1.json
  def destroy
    @zone = Zone.find(params[:id])
    @result = Store::last_record(@zone, Zone.all.count)

    respond_to do |format|
      flash_message @result[0], @result[1]
      format.html { redirect_to admin_zones_url }
      format.json { head :no_content }
    end
  end
end
