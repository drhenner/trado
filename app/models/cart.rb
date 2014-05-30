# Cart Documentation
#
# The cart table is designed as a session stored container (current_cart) for all the current user's cart item. 
# This is destroyed if abandoned for more than a day or the associated order has been completed.

# == Schema Information
#
# Table name: carts
#
#  id             :integer          not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class Cart < ActiveRecord::Base

  has_many :cart_items,                         :dependent => :delete_all
  has_many :cart_item_accessories,              :through => :cart_items
  
  has_many :skus,                               :through => :cart_items

  # Adds a new cart item or increases the quantity and weight of a cart item - including any assocated accessories
  #
  # @return [Object] new or updated cart item
  def add_cart_item sku, item_quantity, accessory
    accessory_current_item = cart_items.where('sku_id = ?',sku.id).includes(:cart_item_accessory).where('cart_item_accessories.accessory_id = ?', accessory.id).first unless accessory.blank?
    # If it can find a SKU with the related accessory, it will assign the current_item. Otherwise it will just find the SKU normally.
  	current_item =  accessory_current_item ? accessory_current_item : cart_items.where('sku_id = ?', sku.id).includes(:cart_item_accessory).where('cart_item_accessories.accessory_id IS NULL').first  
    # If the requested item has matching accessory requests, increase quantity. Otherwise, create new item.
    if (current_item && accessory.blank? && current_item.cart_item_accessory.nil?) || (current_item && !accessory.blank? && !current_item.cart_item_accessory.nil?)
  		current_item.update_quantity((current_item.quantity+item_quantity.to_i), accessory)
      current_item.update_weight(current_item.quantity, sku.weight, accessory)
    # Create new cart item with (possibly) new cart item accessory
  	else 
      unless accessory.blank?
        current_item = cart_items.build(:price => (sku.price + accessory.price), :sku_id => sku.id)
        current_item.build_cart_item_accessory(:price => accessory.price, :accessory_id => accessory.id)
      else
        current_item = cart_items.build(:price => sku.price, :sku_id => sku.id)
      end
      current_item.update_quantity(item_quantity.to_i, accessory)
      current_item.update_weight(item_quantity.to_i, sku.weight, accessory)
  	end
  	current_item #return new item either by quantity or new cart item
  end

  # Decreases the quantity and weight of a cart item, including any associated accessories
  #
  # @return [Object] current cart item
  def decrement_cart_item_quantity cart_item_id
    current_item = cart_items.find(cart_item_id)
    if current_item.quantity > 1
      current_item.update_quantity((current_item.quantity-1), current_item.cart_item_accessory)
      current_item.update_weight(current_item.quantity, current_item.sku.weight, current_item.cart_item_accessory ? current_item.cart_item_accessory.accessory : nil)
    else
      current_item.destroy
    end
    current_item
  end

  # Calculates the total price of a cart
  #
  # @return [Decimal] total sum of cart items
  def total_price 
  	cart_items.to_a.sum { |item| item.total_price }
  end
  
  private

  # Deletes redundant carts which are more than 12 hours old
  #
  # @return [nil]
  def self.clear_carts
    where("updated_at < ?", 12.hours.ago).destroy_all
  end
  
end
