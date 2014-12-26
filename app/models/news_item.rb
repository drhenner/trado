# NewsItem Documentation
#
# The news_items table is a collection of news items to be displayed in a carousel on the homepage.

# == Schema Information
#
# Table name: news_items
#
#  id                               :integer          not null, primary key
#  headline                         :string(255)  
#  content                          :text          
#  published_date                   :datetime
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#
class NewsItem < ActiveRecord::Base
    attr_accessible :headline, :content, :published_date

    validate :headline, :content, :published_date,              presence: true
    validate :headline,                                         uniqueness: true

    default_scope { order(published_date: :desc) }
end
