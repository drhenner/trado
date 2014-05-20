class AddDefaultValueToStatusColumnInOrder < ActiveRecord::Migration
  def change
    change_column :orders, :status, :string, :default => 'review'
  end
end
