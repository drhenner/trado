# Accessory Documentation
#
# The accessory table allows administrators to add additional items to a product and it's overall price.
# A product can have many accessories. The weight of accessories effects the end shipping calculation.

# == Schema Information
#
# Table name: accessories
#
#  id               :integer          not null, primary key
#  name             :string(255)      
#  part_number      :integer  
#  price            :decimal          precision(8), scale(2)      
#  weight           :decimal          precision(8), scale(2) 
#  cost_value       :decimal          precision(8), scale(2)     
#  active           :boolean          default(true)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class Accessory < ActiveRecord::Base

  attr_accessible :name, :part_number, :price, :weight, :cost_value, :active

  has_many :cart_item_accessories
  has_many :cart_items,                             :through => :cart_item_accessories
  has_many :carts,                                  :through => :cart_items
  has_many :order_item_accessories,                 :dependent => :restrict_with_exception
  has_many :order_items,                            :through => :order_item_accessories, :dependent => :restrict_with_exception
  has_many :orders,                                 :through => :order_items
  has_many :accessorisations,                       :dependent => :delete_all
  has_many :products,                               :through => :accessorisations

  validates :name, :part_number,                    :presence => true, :uniqueness => { :scope => :active }
  validates :part_number,                           :numericality => { :only_integer => true, :greater_than_or_equal_to => 1 }

  after_update :update_cart_item_accessories_weight

  # Grabs an array of records which have their active field set to true
  #
  # @return [Array] list of active accessories
  def self.active
    where(['accessories.active = ?', true])
  end

  # If the record's weight has changed, update all associated cart_item_accessorie parent cart_item records with the new weight
  #
  def update_cart_item_accessories_weight
    if self.weight_changed?
      cart_item_accessories = CartItemAccessory.where(:accessory_id => id)
      cart_item_accessories.each do |item|
        item.cart_item.update_column(:weight, (item.quantity*(item.cart_item.sku.weight + weight)))
      end
    end
  end

end
