class AddStoreIntroductionFieldToSettings < ActiveRecord::Migration
  def change
    add_column :store_settings, :introduction, :text
  end
end
