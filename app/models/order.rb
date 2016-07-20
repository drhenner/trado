# Order Documentation
#
# The order table handles all the data associated to a current, completed or failed order. 
# It is updated throughout the order process and discarded if the order is not completed within 2 days. 
# Each order has an associated transaction which contains more information on the payment process. 
  
# == Schema Information
#
# Table name: orders
#
#  id                                     :integer              not null, primary key
#  ip_address                             :string(255)      
#  email                                  :string(255)     
#  user_id                                :integer     
#  cart_id                                :integer
#  delivery_id                            :integer        
#  shipping_status                        :integer              default(0)   
#  shipping_date                          :datetime 
#  actual_shipping_cost                   :decimal              precision(8), scale(2) 
#  express_token                          :string(255) 
#  express_payer_id                       :string(255) 
#  net_amount                             :decimal              precision(8), scale(2)
#  tax_amount                             :decimal              precision(8), scale(2) 
#  gross_amount                           :decimal              precision(8), scale(2) 
#  terms                                  :boolean
#  consignment_number                     :string(255)
#  created_at                             :datetime             not null
#  updated_at                             :datetime             not null
#
require 'reportatron_4000'

class Order < ActiveRecord::Base
  STARTING_LEGACY_ORDER_ID = 13439331

  attr_accessible :shipping_status, :shipping_date, :actual_shipping_cost, 
  :email, :delivery_id, :ip_address, :user_id, :cart_id, :express_token, :express_payer_id,
  :net_amount, :tax_amount, :gross_amount, :terms, :delivery_service_prices, 
  :delivery_address_attributes, :billing_address_attributes, :created_at, :consignment_number, :invoice_id, :payment_type, :status
  
  has_many :order_items,                                                dependent: :destroy
  has_many :transactions,                                               -> { order(created_at: :desc) }, dependent: :destroy
  has_many :products,                                                   through: :order_items
  has_many :skus,                                                       through: :order_items

  belongs_to :cart
  belongs_to :delivery,                                                 class_name: 'DeliveryServicePrice'
  has_one :delivery_address,                                            -> { where addressable_type: 'OrderShipAddress'}, class_name: 'Address', dependent: :destroy
  has_one :billing_address,                                             -> { where addressable_type: 'OrderBillAddress'}, class_name: 'Address', dependent: :destroy
  has_one :delivery_service,                                            through: :delivery

  # validates :actual_shipping_cost,                                      presence: true, :if => :completed?
  validates :email,                                                     presence: { message: 'is required' }, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
  validates :delivery_id,                                               presence: { message: 'Delivery option must be selected.'}                                                                                                                  
  validates :terms,                                                     inclusion: { :in => [true], message: 'Please confirm your acceptance of our terms and conditions to complete your order.' }
  validates :payment_type,                                              presence: true
  validates :legacy_order_id,                                           uniqueness: true, allow_nil: true

  scope :complete,                                                      -> { active.includes(:transactions).where.not(transactions: { order_id: nil } ) }
  scope :incomplete,                                                    ->{ includes(:transactions).where(transactions: { order_id: nil } ) }

  scope :count_per_month,                                               -> { active.order("EXTRACT(month FROM transactions.updated_at)").group("EXTRACT(month FROM transactions.updated_at)").count }

  scope :last_transaction_collection,                                   -> { select('DISTINCT orders.id').joins(:transactions).active.where("transactions.created_at = (SELECT MAX(transactions.created_at) FROM transactions WHERE transactions.order_id = orders.id)") }

  scope :pending_collection,                                            -> { last_transaction_collection.where(transactions: { payment_status: 0 } ) }

  scope :completed_collection,                                          -> { last_transaction_collection.where(transactions: { payment_status: 1 } ) }

  scope :failed_collection,                                             -> { last_transaction_collection.where(transactions: { payment_status: 2 } ) }

  scope :gross_total,                                                   -> { completed_collection.sum('transactions.gross_amount') }

  scope :net_total,                                                     -> { completed_collection.sum('transactions.net_amount') }

  scope :tax_total,                                                     -> { completed_collection.sum('transactions.tax_amount') }

  scope :prev,                                                          ->(id) { where('id < ?', id).last }

  accepts_nested_attributes_for :delivery_address
  accepts_nested_attributes_for :billing_address

  after_create :assign_legacy_order_id

  enum shipping_status: [:pending, :dispatched]
  enum payment_type: [:paypal, :cheque, :bank_transfer]
  enum status: [:active, :cancelled]

  # Upon completing the checkout process, transfer the cart item data to new order item records 
  #
  # @param cart [Object]
  def transfer cart
    self.order_items.destroy_all
  	cart.cart_items.each do |item|
      @order_item = self.order_items.build(price: item.price, quantity: item.quantity, sku_id: item.sku_id, weight: item.weight, order_id: self.id)
      @order_item.build_order_item_accessory(accessory_id: item.cart_item_accessory.accessory_id, price: item.cart_item_accessory.price, quantity: item.cart_item_accessory.quantity) unless item.cart_item_accessory.nil?
      @order_item.save!
  	end
  end

  # Update the current order's net_amount, tax_amount and gross_amount attribute values
  # And assigns the order to the current_cart stored in session
  #
  # @param cart [Object]
  # @param current_tax_rate [Decimal]
  def calculate cart, current_tax_rate
    tax_amount = (cart.total_price + delivery.price)*current_tax_rate
    self.update(
      :cart_id => cart.id,
      :net_amount => cart.total_price,
      :tax_amount => tax_amount,
      :gross_amount => cart.total_price + delivery.price + tax_amount
    )
    self.save(validate: false)
  end

  # Returns true if the last associated transaction to the order is marked as complete
  #
  # @return [Boolean]
  def completed?
    latest_transaction.completed? unless transactions.empty?
  end

  # Returns true if the order is completed, marked as dispatched, consignment is not nil and has changed
  #
  # @return [Boolean]
  def new_order_tracking_mailer?
    completed? && dispatched? && tracking? ? true : false
  end

  def self.dashboard_data
    return {
      :completed => completed_collection.count,
      :pending => pending_collection.count,
      :failed => failed_collection.count,
      :gross_total => gross_total,
      :net_total => net_total,
      :tax_total => tax_total,
      :completed_per_month => Reportatron4000.parse_count_per_month(Order.completed_collection.count_per_month),
      :failed_per_month => Reportatron4000.parse_count_per_month(Order.failed_collection.count_per_month),
      :paypal_fee_total => completed_collection.sum('transactions.fee'),
      :active_carts => Cart.all.count,
      :incomplete_orders => Order.incomplete.count
    }
  end

  def tracking?
    self.consignment_number.nil? || self.delivery_service.tracking_url.nil? ? false : true
  end

  def assign_legacy_order_id
    prev_order = Order.prev(id)
    self.update_column(:legacy_order_id, prev_order.legacy_order_id.present? ? prev_order.legacy_order_id+1 : STARTING_LEGACY_ORDER_ID)
  end

  def latest_transaction
    transactions.first
  end

  def restore_stock!
    if self.cancelled?
      self.order_items.each do |item|
        sku = Sku.find(item.sku_id)
        description = "Cancelled Order ##{self.id}"
        stock_adjustment = StockAdjustment.new(description: description, adjustment: item.quantity, sku_id: item.sku_id)
        stock_adjustment.save!
      end
    end
  end
end