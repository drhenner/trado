require 'carmen'

class CreateAlphaTwoCodesJob < ActiveJob::Base
    queue_as :default

    def perform
        Country.all.each do |country|
            obj = Carmen::Country.named(country.name)
            next if obj.nil?
            country.update_column(:alpha_two_code, obj.code)
        end
    end
end

