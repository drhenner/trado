class CreateNewsItems < ActiveRecord::Migration
  def change
    create_table :news_items do |t|
      t.string :headline
      t.text :content
      t.datetime :published_date

      t.timestamps
    end
  end
end
