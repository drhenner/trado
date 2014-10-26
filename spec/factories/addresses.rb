FactoryGirl.define do
    factory :address do
        active false
        default false
        first_name { Faker::Name.first_name }
        last_name { Faker::Name.last_name }
        company { Faker::Company.name }
        address { Faker::Address.street_address }
        city { Faker::Address.city }
        county { Faker::Address.state }
        postcode { Faker::Address.zip_code }
        country { Faker::Address.country }
        telephone { Faker::PhoneNumber.phone_number }

        association :order
    end
end