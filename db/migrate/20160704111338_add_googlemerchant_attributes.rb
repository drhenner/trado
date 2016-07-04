class AddGooglemerchantAttributes < ActiveRecord::Migration
    def self.up
        add_column :products, :googlemerchant_brand, :string
        add_column :products, :googlemerchant_category, :string
    end

    def self.down
        remove_column :products, :googlemerchant_brand, :string
        remove_column :products, :googlemerchant_category, :string
    end
end
