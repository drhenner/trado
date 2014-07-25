# Shipping Documentation
#
# The shipping table contains a list of available shipping methods, each with a description and price. 
# These are then assigned a tier value, in order to determine the correct shipping method for the dimensions of the product/order.

# == Schema Information
#
# Table name: shippings
#
#  id             :integer          not null, primary key
#  name           :string(255)          
#  price          :decimal          precision(8), scale(2)
#  description    :text          
#  active         :boolean          default(true)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class Shipping < ActiveRecord::Base

  attr_accessible :name, :price, :description, :active, :zone_ids

  has_many :tiereds,                                    :dependent => :delete_all
  has_many :tiers,                                      :through => :tiereds
  has_many :destinations,                               :dependent => :delete_all
  has_many :zones,                                      :through => :destinations
  has_many :countries,                                  :through => :zones
  has_many :orders,                                     :dependent => :restrict_with_exception

  validates :name, :price, :description,                :presence => true
  validates :name,                                      :uniqueness => { :scope => :active }, :length => {:minimum => 10, :message => :too_short}
  validates :description,                               :length => { :maximum => 200, :message => :too_long }
  validates :price,                                     :format => { :with => /\A(\$)?(\d+)(\.|,)?\d{0,2}?\z/ }

  # Grabs an array of records which have their active field set to true
  #
  # @return [array] list of active shippings
  def self.active
    where(['shippings.active = ?', true])
  end

end
