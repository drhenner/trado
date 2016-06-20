class AddLegacyOrderIdAndInvoiceIdToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :legacy_order_id, :integer
    add_column :orders, :invoice_id, :integer
  end
end
