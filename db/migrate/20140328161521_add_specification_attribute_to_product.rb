class AddSpecificationAttributeToProduct < ActiveRecord::Migration
  def change
    add_column :products, :specification, :text
  end
end
