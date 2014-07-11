class ChangeDefaultValueForAlertTypeInStoreSetting < ActiveRecord::Migration
  def change
    change_column :store_settings, :alert_type, :string, default:'warning'
  end
end
