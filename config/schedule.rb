set :output, "log/schedule.log"

job_type :rbenv_rake, %Q{cd :path && RAILS_ENV=development bundle exec rake :task --silent :output }
job_type :rbenv_runner, %Q{cd :path && RAILS_ENV=development bundle exec rails runner :task --silent :output }

every 1.day, at: '4:00am' do
    rbenv_runner "Cart.clear_carts"
end

every 1.day, at: '5:00 am' do
    rbenv_rake "-s sitemap:refresh"
end

every 1.week, at: '8:00 am' do
    rbenv_runner "RegeneratePopularCountriesJob.perform_later"
end

every 1.day, at: '8:30 am' do
    rbenv_runner "StockWarningEmailJob.perform_later"
end

every 1.hour do
    rbenv_runner "SendDispatchedOrderEmailsJob.perform_later"
end