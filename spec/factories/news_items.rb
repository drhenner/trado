# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :news_item do
    headline "MyString"
    content "MyText"
    published_date "2014-12-24 22:40:28"
  end
end
