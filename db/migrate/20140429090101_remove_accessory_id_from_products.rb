class RemoveAccessoryIdFromProducts < ActiveRecord::Migration
  def change
    remove_column :skus, :accessory_id
  end
end
