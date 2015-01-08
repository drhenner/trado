namespace :export do

    desc "Export country list from each delivery service"
    task :countries => :environment do
        delivery_services = DeliveryService.active.all
        puts "Exporting countries from delivery services!"
        File.open("countries.txt", "w") do |f|
            f << "-------------"
            f << "\n"
            delivery_services.each do |service|
                f << service.full_name
                f << "\n"
                f << "-------------"
                f << "\n"
                service.countries.each do |country|
                    f << country.name
                    f << "\n"
                end
                f << "\n"
                f << "-------------"
                f << "\n"
            end
        end
    end
end