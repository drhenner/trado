# Tag Documentation
#
# The tag table contains a list of tags which belong to products. These are notably used to improve search results and site SEO.

# == Schema Information
#
# Table name: tags
#
#  id             :integer          not null, primary key
#  name           :string(255)          
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class Tag < ActiveRecord::Base

  attr_accessible :name

  has_many :taggings,               :dependent => :delete_all
  has_many :products,               :through => :taggings

  # Creates or updates the list of tags for an object
  #
  # @return [array]
  def self.add value, product_id
    @tags = value.split(/,\s*/)   
    @tags.each do |t|
        next unless Tag.where('name = ?', t).includes(:taggings).where(:taggings => { :product_id => product_id }).empty?
        new_tag = Tag.find_by_name(t).nil? ? Tag.create(name: t) : Tag.find_by_name(t)
        Tagging.create(:product_id => product_id, :tag_id => new_tag.id)
    end
  end

  # Deletes all tags associated to the product if the string is blank.
  # Or deletes tags not contained within the comma separated string, including tagging records.
  #
  # @return [nil]
  def self.del value, product_id
    if value.blank?
      Tag.includes(:taggings).where(:taggings => { :product_id => product_id }).destroy_all 
    else
      @tags = value.split(/,\s*/)
      Tag.where('name NOT IN (?)', @tags).includes(:taggings).where(:taggings => { :product_id => product_id }).destroy_all
    end
  end

end
