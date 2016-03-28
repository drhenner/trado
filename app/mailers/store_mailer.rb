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
        mail(to: Store.settings.email, 
            from: "#{@name} <#{@email}>",
            subject: "#{Store::settings.name} contact form message"
        ) do |format|
            format.html { render "admin/emails/store/contact_message", layout: "../themes/#{Store.settings.theme.name}/layout/contact" }
            format.text { render "admin/emails/store/contact_message", layout: "../themes/#{Store.settings.theme.name}/layout/contact" }
        end
    end
end