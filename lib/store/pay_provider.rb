module Store

    class PayProvider
        attr_reader :order, :cart, :ip_address, :provider, :session

        # Initial price logic which builds attributes to force behaviour, not data interaction
        #
        # @overload set(data)
        #   @param [Object] order
        #   @param [Object] cart
        #   @param [String] ip address
        #   @param [String] payment provider
        #   @param [Hash] session store
        # @return [String] url redirects
        def initialize data
            @order          = data[:order]
            @cart           = data[:cart]
            @ip_address     = data[:ip_address]
            @provider       = data[:provider]
            @session        = data[:session]
        end

        # This is the backbone of the PayProvider class, defining the object which it will interact with for payment related tasks
        #
        # @return [Object] correct pay provider object
        def provider
            if @provider == 'express-checkout'
                return Payatron4000::Paypal
            end
        end

        # Triggers the build method, under the respective payment provider class
        #
        # @return [String] redirect url
        def build
            provider.build(order, cart, ip_address)
        end

        # Triggers the complete method, under the respective payment provider class
        #
        # @return [String] redirect url
        def complete
            provider.complete(order, session)
        end
    end
end