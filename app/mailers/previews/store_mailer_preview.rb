class StoreMailerPreview < BasePreview

    def message
        params = 
        {
            :name =>  'Tom Dallimore',
            :email => 'me@tomdallimore.com',
            :telephone => '02127 399432',
            :message => 'Hi, this is a message'
        }
        StoreMailer.message(params)
    end
end