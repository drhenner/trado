class CartItemsController < ApplicationController

  before_filter :destroy_estimate_shipping, :only => [:create, :update]

  skip_before_filter :authenticate_user!

  # POST /cart_items
  # POST /cart_items.json
  def create
    sku = Sku.find(params[:cart_item][:sku_id])
    @cart = current_cart #references the current cart which was defined in application controller
    accessory = params[:cart_item][:cart_item_accessory].nil? ? nil : Accessory.where('id = ?', params[:cart_item][:cart_item_accessory][:accessory_id]).first
    @cart_item = @cart.add_cart_item(sku, params[:cart_item][:quantity], accessory) #uses add_cart_item method in cart.rb to check if the cart item already exists in the cart and responds accordingly
    # Need to query the database again since it will need to retrieve the quantity sum of cart_items with accessories and without accessories
    @quantity = @cart.cart_items.where('sku_id = ?', @cart_item.sku_id).sum(:quantity) + @cart_item.quantity
    respond_to do |format|
      if sku.stock >= @quantity #checks to make sure the requested quantity is not more than the current DB stock
        if @cart_item.save
          format.js { render :partial => 'carts/update', :formats => [:js] }
        else
          format.json { render json: @cart_item.errors, status: :unprocessable_entity }
        end
      else
        format.js { render :partial => 'carts/insufficient_stock/update', :formats => [:js] }
      end
    end
  end

  def update
    @cart_item = CartItem.find(params[:id])
    @quantity = current_cart.cart_items.where('sku_id = ? AND id != ?', @cart_item.sku_id, @cart_item.id).sum(:quantity) + params[:cart_item][:quantity].to_i
      respond_to do |format|
        if @cart_item.sku.stock >= @quantity #checks to make sure the requested quantity is not more than the current DB stock
          if @cart_item.update_attributes(params[:cart_item])
            if @cart_item.quantity == 0 
              @cart_item.destroy 
            else
              accessory = @cart_item.cart_item_accessory ? @cart_item.cart_item_accessory.accessory : nil
              @cart_item.update_weight(params[:cart_item][:quantity], @cart_item.sku.weight, accessory)
              @cart_item.cart_item_accessory.quantity = params[:cart_item][:quantity] unless @cart_item.cart_item_accessory.nil?
              @cart_item.save!
            end
            format.js { render :partial => 'carts/update', :format => [:js] }
            format.json { head :no_content }
          else
            format.json { render json: @cart_item.errors, status: :unprocessable_entity }
          end
        else
          format.js { render :partial => 'carts/insufficient_stock/update', :formats => [:js] }
        end
      end
  end

  # DELETE /cart_items/1
  # DELETE /cart_items/1.json
  def destroy
    @cart = current_cart
    cart_item = CartItem.find(params[:id])
    @cart_item = @cart.decrement_cart_item_quantity(cart_item.id)
    
    respond_to do |format|
      if @cart_item.save
        format.js { render :partial => 'carts/update', :formats => [:js] }
        format.json { head :no_content }
      end
    end
  end  

  # If a new cart item is created or an existing one is updated,
  # remove the estimate as it is now obselete
  #
  def destroy_estimate_shipping
    session[:estimate_country] = session[:estimate_price] = session[:estimate_shipping] = nil
  end
end
