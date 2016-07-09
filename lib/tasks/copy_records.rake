namespace :copy_records do

    desc "Copy delivery service prices between delivery services"
    task :delivery_services, [:base_id, :target_id] => :environment do |t, args|
        base_delivery_service = DeliveryService.find(args.base_id)
        target_delivery_service = DeliveryService.find(args.target_id)

        puts "Copying price records from #{base_delivery_service.full_name} to #{target_delivery_service.full_name}..."
        puts "--------------------"
        base_delivery_service.active_prices.each do |price|
            new_price = price.dup
            new_price.delivery_service_id = target_delivery_service.id
            new_price.save(validate: false)
            puts "Created #{price.code} for #{target_delivery_service.full_name}!"
        end
    end
end