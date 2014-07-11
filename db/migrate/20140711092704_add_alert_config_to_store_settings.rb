class AddAlertConfigToStoreSettings < ActiveRecord::Migration
  def change
    add_column :store_settings, :alert_active, :boolean, default: false
    add_column :store_settings, :alert_message, :text, default: 'Type your alert message here...'
    add_column :store_settings, :alert_type, :string, default: 'orange'
  end
end
