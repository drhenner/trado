# Country Documentation
#
# The country table is a list of available countries available to a user when they select their billing and shipping country. 
# It has and belongs to zones and tax_rates.

# == Schema Information
#
# Table name: countries
#
#  id                   :integer          not null, primary key
#  name                 :string(255)     
#  language             :string(255)
#  iso                  :string(255)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
class Country < ActiveRecord::Base

  attr_accessible :name, :iso, :available, :language

  has_many :zonifications,                      :dependent => :delete_all
  has_many :zones,                              :through => :zonifications

  validates :name,                              :uniqueness => true, :presence => true

  default_scope order('name ASC')

end
