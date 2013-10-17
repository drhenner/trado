class Shipping < ActiveRecord::Base
  attr_accessible :name, :price
  has_many :tiereds
  has_many :tiers, :through => :tiereds
end
