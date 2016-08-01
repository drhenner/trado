class AddOverrideDeliveryToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :override_delivery_name, :string
    add_column :orders, :override_delivery_tracking, :string
  end
end
