class Admin::Products::SkusController < ApplicationController

  before_filter :authenticate_user!

  def edit
    @form_sku = Sku.find(params[:id])
    render :partial => '/admin/products/skus/edit', :format => [:js]
  end

  # Updating a SKU
  #
  # If the SKU is not associated with orders, update the current record.
  # Else create a new SKU with the new attributes with the id of the parent product.
  # Set the old SKU as inactive. (It is now archived for reference by previous orders).
  # Delete any cart items associated with the old sku.
  def update
    @sku = Sku.find(params[:id])
    unless @sku.orders.empty? || params[:sku][:stock]
      Store::inactivate!(@sku)
      @sku = Sku.new(params[:sku])
      @old_sku = Sku.find(params[:id])
      @sku.product_id = @old_sku.product.id
      extra_values = {:product_id => @old_sku.product.id, :stock => @old_sku.stock, :stock_warning_level => @old_sku.stock_warning_level}
      params[:sku].merge!(extra_values)
    end

    respond_to do |format|
      if @sku.update_attributes(params[:sku])
        if @old_sku
          Store::inactivate!(@old_sku)
          CartItem.where('sku_id = ?', @old_sku.id).destroy_all
        end
        format.js { render :partial => 'admin/products/skus/success', :format => [:js] }
      else
        @form_sku = Sku.find(params[:id])
        Store::activate!(@form_sku)
        @form_sku.attributes = params[:sku]
        format.json { render :json => { :errors => @sku.errors.full_messages}, :status => 422 }
      end
    end
  end

  # Destroying a SKU
  #
  # Various if statements to handle how a SKU is dealt with then checking order and cart associations
  # If sku count is less than 2 for the associated product, avoid delete or soft delete.
  # If there are no carts or orders: destroy the sku.
  # If there are orders but no carts: deactivate the sku.
  # If there are carts but no orders: delete all cart items then delete the sku.
  # If there are orders and carts: deactivate the sku and delete all cart items.
  def destroy
    @sku = Sku.find(params[:id])

    respond_to do |format|      
      if @sku.product.skus.active.count > 1
        if @sku.carts.empty? && @sku.orders.empty?
          @sku.destroy        
        elsif @sku.carts.empty? && !@sku.orders.empty?
          Store::inactivate!(@sku)
        elsif !@sku.carts.empty? && @sku.orders.empty?
          CartItem.where('sku_id = ?', @sku.id).destroy_all
          @sku.destroy   
        else
          Store::inactivate!(@sku)
          CartItem.where('sku_id = ?', @sku.id).destroy_all
        end
        format.js { render :partial => "admin/products/skus/destroy", :format => [:js] }
      else
        format.js { render :partial => 'admin/products/skus/failed_destroy',:format => [:js] }
      end
    end
  end
end
