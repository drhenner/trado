class MasterInvoiceIdToStoreSettings < ActiveRecord::Migration
  def change
    add_column :store_settings, :master_invoice_id, :integer, default: 3027
  end
end
