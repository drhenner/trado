# Address Documentation
#
# The address table provides support for handling order and user addresses. 
# It has a polymorphic relation so can be utilised by various models.

# == Schema Information
#
# Table name: addresses
#
#  id                       :integer          not null, primary key
#  addressable_id           :integer          
#  addressable_type         :string(255)      
#  first_name               :string(255)      
#  last_name                :string(255) 
#  address                  :string(255)      
#  company                  :string(255)  
#  telephone                :string(255)        
#  city                     :string(255) 
#  county                   :string(255)      
#  country                  :string(255)      
#  postcode                 :string(255)
#  active                   :boolean          default(true)      
#  default                  :boolean          default(false)      
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#
class Address < ActiveRecord::Base

  attr_accessible :active, :address, :city, :company, :country, :county, :addressable_id,
  :addressable_type, :default, :first_name, :last_name, :postcode, :telephone, :order_id

  belongs_to :order
  belongs_to :addressable,                                          polymorphic: true

  validates :first_name, :last_name, 
  :address, :city, :postcode, :country, :telephone,                 presence: true

  # Combines the first and last name of an address
  #
  # @return [String] first and last name concatenated
  def full_name
    [first_name, last_name].join(' ')
  end

  def full_address
    cnty = Country.find_by_name(country)
    alpha_two_code = cnty.nil? ? 'GB' : cnty.alpha_two_code
    {
      name: full_name,
      address1: address,
      city: city,
      zip: postcode,
      state: county,
      country: alpha_two_code,
      telephone: telephone
    }
  end
end
