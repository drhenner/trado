class AddVisibleAlertAttributeToPage < ActiveRecord::Migration
  def change
    add_column :pages, :visible_alert, :boolean, default: false
  end
end
