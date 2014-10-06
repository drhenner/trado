class StoreMailer < ActionMailer::Base

    # Deliver a message to the administrator
    # These emails are created by users visiting the site who have questions for the store owner
    #
    # @param param [Hash]
    def contact_message params
        @name = params[:name]
        @email = params[:email]
        @telephone = params[:telephone]
        @message = params[:message]
        
        mail(from: "#{@name} <#{@email}>",
            to: Store::settings.email, 
            subject: "#{Store::settings.name} contact form message",
            template_path: 'mailer/store',
            template_name: 'message'
        )
    end
end