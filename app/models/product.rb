# Product Documentation
#
# The product table contains the global data for any given product. 
# It has associations to attachments, tags and skus.
# More detailed information and different product variations are maintained within the Sku table.

# == Schema Information
#
# Table name: products
#
#  id                       :integer          not null, primary key
#  part_number              :string      
#  name                     :string(255)
#  description              :text
#  short_description        :text
#  meta_description         :string(255)
#  specification            :text
#  weighting                :integer 
#  sku                      :string(255)
#  featured                 :boolean 
#  single                   :boolean
#  active                   :boolean          default(true)
#  category_id              :integer    
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#
class Product < ActiveRecord::Base

  attr_accessible :name, :meta_description, :description, :weighting, :sku, :part_number, 
  :accessory_ids, :attachments_attributes, :tags_attributes, :skus_attributes, :category_id, 
  :featured, :short_description, :related_ids, :specification, :single

  validates :name, :meta_description, :description, 
  :part_number, :sku, :weighting, :category_id,               :presence => true
  validates :part_number, :sku, :name,                        :uniqueness => { :scope => :active }
  validates :name, :meta_description,                         :length => {:minimum => 10, :message => :too_short }
  validates :description,                                     :length => {:minimum => 20, :message => :too_short }
  validates :skus,                                            :tier => true, :on => :save
  validates :short_description,                               :length => { :maximum => 100, :message => :too_long }
  validates :part_number,                                     :numericality => { :only_integer => true, :greater_than_or_equal_to => 1 }                                                         
  validate :single_product


  has_many :searches
  has_many :skus,                                             :dependent => :delete_all
  has_many :orders,                                           :through => :skus
  has_many :carts,                                            :through => :skus
  has_many :taggings,                                         :dependent => :delete_all
  has_many :tags,                                             :through => :taggings, :dependent => :delete_all
  has_many :attachments,                                      as: :attachable, :dependent => :delete_all
  has_many :accessorisations,                                 :dependent => :delete_all
  has_many :accessories,                                      :through => :accessorisations
  has_and_belongs_to_many :related,                           class_name: "Product", 
                                                              join_table: :related_products, 
                                                              foreign_key: :product_id, 
                                                              association_foreign_key: :related_id
  belongs_to :category

  accepts_nested_attributes_for :attachments
  accepts_nested_attributes_for :tags
  accepts_nested_attributes_for :skus

  searchkick word_start: [:name, :part_number, :sku], conversions: "conversions"

  default_scope order('weighting DESC')

  extend FriendlyId
  friendly_id :name, use: :slugged

  # Search paramters for elasticsearch
  #
  # @return [nil]
  def search_data
    {
      name: name,
      conversions: searches.group("query").count
    }
  end

  # Sets the related record's active field as false
  #
  # @return [Object] an inactive record
  def inactivate!
    self.update_column(:active, false)
  end

  # Sets the related record's active field as true
  #
  # @return [Object] an active record
  def activate!
    self.update_column(:active, true)
  end

  # Grabs an array of records which have their active field set to true
  #
  # @return [Array] list of active products
  def self.active
    where(['products.active = ?', true])
  end

  # Detects if a product has more than one SKU when attempting to set the single product field as true
  # The sku association needs to map an attribute block in order to count the number of records successfully
  # The standard self.skus.count is performed using the record ID, which none of the SKUs currently have
  #
  # @return [Boolean]
  def single_product
    if self.single && self.skus.map { |s| s.active }.count > 1
      errors.add(:single, " product cannot be set if the product has more than one SKU.")
      return false
    end
  end

end
