class StoreMailerPreview < ActionMailer::Preview

    def contact_message
        params = 
        {
            :name =>  'Tom Dallimore',
            :email => 'me@tomdallimore.com',
            :telephone => '02127 399432',
            :message => 'Hi, this is a message'
        }
        StoreMailer.contact_message(params)
    end
end