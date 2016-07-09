# Sku Documentation
#
# The Sku table manages all the product variations. 

# == Schema Information
#
# Table name: skus
#
#  id                         :integer          not null, primary key
#  code                       :string(255)      
#  length                     :decimal          precision(8), scale(2) 
#  weight                     :decimal          precision(8), scale(2) 
#  thickness                  :decimal          precision(8), scale(2) 
#  stock                      :integer 
#  stock_warning_level        :integer 
#  cost_value                 :decimal          precision(8), scale(2) 
#  price                      :decimal          precision(8), scale(2) 
#  product_id                 :integer 
#  active                     :boolean          default(true)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
class Sku < ActiveRecord::Base
  
  attr_accessible :cost_value, :price, :code, :stock, :stock_warning_level, :length, 
  :weight, :thickness, :product_id, :accessory_id, :active, :variants_attributes
  
  has_many :cart_items
  has_many :carts,                                                    through: :cart_items
  has_many :order_items,                                              dependent: :restrict_with_exception
  has_many :orders,                                                   through: :order_items, dependent: :restrict_with_exception
  has_many :notifications,                                            as: :notifiable, dependent: :destroy
  has_many :active_notifications,                                     -> { where(sent: false) }, class_name: 'Notification', as: :notifiable
  has_many :stock_adjustments,                                        dependent: :destroy
  has_one :category,                                                  through: :product
  belongs_to :product,                                                inverse_of: :skus
  has_many :variants,                                                 dependent: :destroy, class_name: 'SkuVariant', inverse_of: :sku
  has_many :variant_types,                                            -> { uniq }, through: :variants

  validates :price, :cost_value, :length, 
  :weight, :thickness, :code,                                         presence: true
  validates :price, :cost_value,                                      format: { with: /\A(\$)?(\d+)(\.|,)?\d{0,2}?\z/ }
  validates :length, :weight, :thickness,                             numericality: { greater_than_or_equal_to: 0 }
  validates :stock, :stock_warning_level,                             presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }, :if => :new_record?
  validate :stock_values,                                             on: :create
  validates :code,                                                    uniqueness: { scope: [:product_id, :active] }
  validate :variant_duplication

  after_update :update_cart_items_weight                             
  
  before_destroy :set_product_as_draft,                               :if => :last_active_sku?

  accepts_nested_attributes_for :variants

  scope :complete,                                                    -> { where('stock IS NOT NULL') }
  scope :stock_warning,                                               -> { where('stock < stock_warning_level') }

  include ActiveScope

  # Validation check to ensure the stock value is higher than the stock warning level value when creating a new SKU
  #
  # @return [Boolean]
  def stock_values
    if self.stock && self.stock_warning_level && self.stock <= self.stock_warning_level
      errors.add(:sku, "stock warning level value must be below your stock count.")
      return false
    end
  end

  # If the record's weight has changed, update all associated cart_items records with the new weight
  #
  def update_cart_items_weight
    cart_items = CartItem.where(sku_id: id)
    cart_items.each do |item|
      item.update_column(:weight, (weight*item.quantity))
    end
  end

  # Joins the parent product SKU and the current SKU with a hyphen
  #
  # @return [String] product SKU and current SKU concatenated
  def full_sku
    [product.sku, code].join('-')
  end

  # Validates the variant combination against the other active SKUs associated with the product
  # If variant combination already exists, return an error to the form
  #
  def variant_duplication
    return false if self.variants.map{|v| v.name.nil?}.include?(true) || self.variants.empty?
    @new_variant = self.variants.map{|v| v.name}.join('/')
    @all_associated_variants = self.product.active_skus.where.not(id: self.id).map{|s| s.variants.map{|v| v.name}.join('/') }
    if @all_associated_variants.include?(@new_variant)
        errors.add(:base, "Variants combination already exists.")
        return false
    end
  end

  # Updates the product's status to 'Draft'
  #
  def set_product_as_draft
    product.draft! if product.published?
  end

  # If the associated parent product has one SKU, return true
  # Else return false
  #
  # @return [Boolean]
  def last_active_sku?
    product.active_skus.count == 1 ? true : false
  end

  # Checks if the product has any stock
  #
  # @return [Boolean]
  def in_stock?
    stock == 0 ? false : true
  end
end
