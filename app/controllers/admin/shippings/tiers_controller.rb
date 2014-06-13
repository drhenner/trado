class Admin::Shippings::TiersController < ApplicationController

  before_filter :authenticate_user!
  layout "admin"
  # GET /tiers
  # GET /tiers.json
  def index
    @tiers = Tier.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tiers }
    end
  end

  # GET /tiers/new
  # GET /tiers/new.json
  def new
    @tier = Tier.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @tier }
    end
  end

  # GET /tiers/1/edit
  def edit
    @tier = Tier.find(params[:id])
  end

  # POST /tiers
  # POST /tiers.json
  def create
    @tier = Tier.new(params[:tier])

    respond_to do |format|
      if @tier.save
        flash[:success] = 'Tier was successfully created.'
        format.html { redirect_to admin_shippings_tiers_url }
        format.json { render json: @tier, status: :created, location: @tier }
      else
        format.html { render action: "new" }
        format.json { render json: @tier.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tiers/1
  # PUT /tiers/1.json
  def update
    @tier = Tier.find(params[:id])
    respond_to do |format|
      if @tier.update_attributes(params[:tier])
        flash[:success] = 'Tier was successfully updated.'
        format.html { redirect_to admin_shippings_tiers_url }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @tier.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tiers/1
  # DELETE /tiers/1.json
  def destroy
    @tier = Tier.find(params[:id])
    @tier.destroy

    respond_to do |format|
      flash[:success] = 'Tier was successfully deleted.'
      format.html { redirect_to admin_shippings_tiers_url }
      format.json { head :no_content }
    end
  end
end
